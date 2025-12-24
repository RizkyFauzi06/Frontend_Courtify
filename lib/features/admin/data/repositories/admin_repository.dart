import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../models/owner_request_model.dart';
import '../models/member_verification_model.dart';

final adminRepositoryProvider = Provider(
  // mendeclare pembungkus admin repository
  (ref) => AdminRepository(
    // api untuk memanggil dio
    ref.watch(dioProvider),
  ), // mengambil nilai dio provider agar bisa di gunakan di file ini
);

class AdminRepository {
  final Dio _dio;
  AdminRepository(this._dio);

  // GET LIST PENGAJUAN
  Future<List<OwnerRequestModel>> getRequests() async {
    try {
      // Sesuaikan URL dengan nama file backend
      final response = await _dio.get('/admin/customers');

      final List data = response.data['pengajuan'] ?? [];
      return data.map((e) => OwnerRequestModel.fromJson(e)).toList();
    } catch (e) {
      return []; // Return kosong kalau error biar gak crash
    }
  }

  // APPROVE REQUEST
  Future<void> approveRequest(int idPengajuan) async {
    try {
      final url = '/admin/setujui_pengajuan'; // url backend

      await _dio.post(url, data: {'Id_pengajuan': idPengajuan});
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memproses.';
    }
  }

  //  REJECT REQUEST (TOLAK)
  Future<void> rejectRequest(int idPengajuan) async {
    try {
      // url backend
      const url = '/admin/tolak_pengajuan';

      await _dio.post(url, data: {'Id_pengajuan': idPengajuan});
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal menolak.';
    }
  }

  Future<List<MemberVerificationModel>> getPendingMembers() async {
    const url = '/admin/verifikasi_membership';

    try {
      print('--- [DEBUG ADMIN] REQUEST KE: $url ---');

      final response = await _dio.get(url);

      print('--- [DEBUG ADMIN] STATUS: ${response.statusCode} ---');
      print('--- [DEBUG ADMIN] DATA RAW: ${response.data} ---');

      final List data = response.data['data'] ?? [];

      if (data.isEmpty) {
        print('--- [DEBUG ADMIN] DATA KOSONG DARI SERVER! ---');
        print(
          'Cek Database: Apakah ID Tingkatan & ID User di tabel Langganan valid?',
        );
      }

      return data.map((e) {
        print('Parsing item: $e'); // Cek mana yang bikin crash
        return MemberVerificationModel.fromJson(e);
      }).toList();
    } catch (e, stack) {
      print('[CRITICAL ERROR] ADMIN REPO: $e');
      print(stack);
      // lempar error biar muncul di layar HP
      throw e.toString();
    }
  }

  // APPROVE / REJECT MEMBER
  Future<void> verifyMember(int idLangganan, bool isAccepted) async {
    try {
      await _dio.post(
        '/admin/verifikasi_membership',
        data: {
          'Id_langganan': idLangganan,
          'Aksi': isAccepted ? 'terima' : 'tolak', // Kirim parameter Aksi
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memproses.';
    }
  }
}
