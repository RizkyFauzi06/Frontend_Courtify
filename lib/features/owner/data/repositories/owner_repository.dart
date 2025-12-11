import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import 'package:frontend_futsal/features/owner/data/models/dashboard_model.dart';
import 'package:frontend_futsal/features/owner/data/models/verification_model.dart';
import 'package:frontend_futsal/features/field/data/models/field_model.dart';

final ownerRepositoryProvider = Provider(
  (ref) => OwnerRepository(ref.watch(dioProvider)),
);

class OwnerRepository {
  final Dio _dio;
  OwnerRepository(this._dio);

  // 1. Get Stats Utama
  Future<DashboardStats> getStats() async {
    try {
      final response = await _dio.get('/dasbor');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      throw 'Gagal memuat statistik.';
    }
  }

  // 2. Get Jam Ramai
  Future<List<JamRamai>> getJamRamai() async {
    try {
      final response = await _dio.get('/dasbor/jam_ramai');
      final List data = response.data['data'] ?? [];
      return data.map((e) => JamRamai.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // 3. Get Lapangan Terlaris
  Future<List<LapanganTerlaris>> getLapanganTerlaris() async {
    try {
      final response = await _dio.get('/dasbor/lapangan_terlaris');
      final List data = response.data['data'] ?? [];
      return data.map((e) => LapanganTerlaris.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<VerificationModel>> getPendingVerifications() async {
    const url = '/owner/verifikasi_pembayaran';
    try {
      final response = await _dio.get(url);

      // Cek isi data di terminal
      print('--- DEBUG DATA VERIFIKASI ---');
      print(response.data);

      final dynamic rawData = response.data;
      List listData = [];

      if (rawData is Map<String, dynamic>) {
        listData = rawData['data'] ?? [];
      } else if (rawData is List) {
        listData = rawData;
      }

      return listData.map((e) => VerificationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      // JANGAN return []; -> LEMPAR ERROR BIAR KELIATAN DI HP
      throw 'Error Koneksi (${e.response?.statusCode}): ${e.message}';
    } catch (e) {
      throw 'Error Parsing: $e';
    }
  }

  // --- FUNGSI VERIFIKASI (SESUAI BACKEND BARU) ---
  Future<void> verifyPayment(int bookingId, bool isAccepted) async {
    try {
      const url = '/owner/verifikasi_pembayaran';
      final statusString = isAccepted ? 'lunas' : 'dibatalkan';

      // 3. Kirim Body JSON sesuai Backend baru
      final body = {
        'Id_pemesanan': bookingId,
        'Status': statusString, // Backend minta 'lunas' atau 'dibatalkan'
      };

      await _dio.post(url, data: body);
    } catch (e) {
      // Tangkap error message dari backend
      if (e is DioException) {
        throw e.response?.data['error'] ?? 'Gagal memproses verifikasi.';
      }
      throw 'Terjadi kesalahan koneksi.';
    }
  }

  // --- A. GET MY FIELDS (Lapangan Saya) ---
  Future<List<FieldModel>> getMyFields({String query = ''}) async {
    try {
      // Kirim parameter ?search=... ke backend
      final response = await _dio.get('/lapangan', queryParameters: {
        'search': query,
      });
      
      final dynamic rawData = response.data;
      List listData = (rawData is Map) ? rawData['data'] : rawData;
      
      return listData.map((e) => FieldModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- B. CREATE FIELD (Tambah Lapangan) ---
  Future<int> createField(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/lapangan', data: data);
      return int.parse(response.data['id_lapangan_baru'].toString());
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal membuat lapangan.';
    }
  }

  // --- C. UPLOAD PHOTO (Foto Lapangan) ---
  Future<void> uploadFieldPhoto(int fieldId, String filePath) async {
    try {
      final url = '/lapangan/$fieldId/upload_foto'; // Sesuaikan Backend
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(filePath),
      });
      await _dio.post(url, data: formData);
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal upload foto.';
    }
  }

  // --- D. DELETE FIELD ---
  Future<void> deleteField(int fieldId) async {
    try {
      await _dio.delete('/lapangan/$fieldId');
    } catch (e) {
      throw 'Gagal menghapus lapangan.';
    }
  }

  // --- E. UPDATE FIELD ---
  Future<void> updateField(int fieldId, Map<String, dynamic> data) async {
    try {
      await _dio.put('/lapangan/$fieldId', data: data);
    } catch (e) {
      throw 'Gagal update lapangan.';
    }
  }
}
