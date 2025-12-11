import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../models/auth_response.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageProvider);
  return AuthRepository(
    dio,
    storage,
  ); // meyimpan nilai dari dio dan storage baru ke provider agar bisa di panggil yang lain
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthResponseModel> login(String email, String password) async {
    final url = '/pengguna/login';
    // Backend Login butuh Huruf Besar
    final body = {'Email': email, 'Password': password};

    try {
      log('--- [DEBUG] MENCOBA LOGIN ---');
      log('BODY: $body');

      // baca API
      final response = await _dio.post(url, data: body);

      log('--- [DEBUG] LOGIN SUKSES, PARSING DATA... ---');

      // Definisi authData
      final authData = AuthResponseModel.fromJson(response.data);

      //Simpan Data ke Storage
      await _storage.write(key: 'token', value: authData.token);
      await _storage.write(key: 'user_role', value: authData.user.role);
      await _storage.write(key: 'user_id', value: authData.user.id);

      // Simpan Profil untuk ProfileScreen
      await _storage.write(key: 'user_name', value: authData.user.namaLengkap);
      await _storage.write(key: 'user_email', value: authData.user.email);
      // Cek null safety untuk foto
      await _storage.write(
        key: 'user_photo',
        value: authData.user.fotoUrl ?? '',
      );

      // Return data yang sudah jadi
      return authData;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw 'System Error: $e';
    }
  }

  // REGISTER
  Future<void> register(String nama, String email, String password) async {
    try {
      final url = '/pengguna/daftar';
      // Backend Register butuh Huruf Besar
      final body = {
        'Nama_lengkap': nama,
        'Email': email,
        'Password': password,
        'Role': 'Customer',
      };

      log('--- REGISTER REQUEST ---');
      log('BODY: $body');

      await _dio.post(url, data: body);
      log('--- REGISTER SUCCESS ---');
    } on DioException catch (e) {
      throw _handleDioError(e); // Panggil fungsi pintar di bawah
    } catch (e) {
      throw 'System Error: $e';
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/pengguna/profil');

      // Backend kirim: {'user': {...}}
      final data = response.data['user'];

      return UserModel.fromJson(data);
    } catch (e) {
      // Kalau gagal, return user dummy biar gak crash
      return UserModel(
        id: '0',
        namaLengkap: 'Gagal Load',
        email: '-',
        role: '-',
        fotoUrl: null,
      );
    }
  }

  String _handleDioError(DioException e) {
    // Log biar kelihatan di terminal
    log('--- DIO ERROR ANALYSIS ---');
    log('Status: ${e.response?.statusCode}');
    log('Data Type: ${e.response?.data.runtimeType}'); // Kita cek tipenya apa
    log('Data Content: ${e.response?.data}');

    // Masalah Koneksi Fisik
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Koneksi Gagal. Cek IP (${AppConstants.baseUrl}) & WiFi.';
    }

    // Masalah Respon Server
    if (e.response != null) {
      final data = e.response?.data;

      // KASUS A: Data berupa MAP ({"error": "..."})
      if (data is Map<String, dynamic>) {
        return data['error'] ??
            data['Error'] ??
            data['message'] ??
            'Terjadi kesalahan (Map)';
      }

      // KASUS B: Data berupa LIST/SET (["Password salah"])
      if (data is List) {
        if (data.isNotEmpty) {
          return data.first.toString(); // Ambil teks pertamanya
        }
        return 'Terjadi kesalahan (List Kosong)';
      }

      // KASUS C: Data berupa String biasa
      return data.toString();
    }

    return 'Error Tak Terduga: ${e.message}';
  }
}
