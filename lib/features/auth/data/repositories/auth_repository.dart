import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(
    dioProvider,
  ); // <--- Ini otomatis update kalau IP berubah
  final storage = ref.watch(storageProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthResponseModel> login(String email, String password) async {
    const url = '/pengguna/login';
    // Backend Login butuh Huruf Besar
    final body = {'Email': email, 'Password': password};

    try {
      // [DEBUG] Tampilkan kita sedang menembak ke IP mana
      log('--- [DEBUG] LOGIN KE: ${_dio.options.baseUrl}$url ---');
      log('BODY: $body');

      final response = await _dio.post(url, data: body);

      log('--- [DEBUG] LOGIN SUKSES, PARSING DATA... ---');

      final authData = AuthResponseModel.fromJson(response.data);

      await _storage.write(key: 'token', value: authData.token);
      await _storage.write(key: 'user_role', value: authData.user.role);
      await _storage.write(key: 'user_id', value: authData.user.id);
      await _storage.write(key: 'user_name', value: authData.user.namaLengkap);
      await _storage.write(key: 'user_email', value: authData.user.email);
      await _storage.write(
        key: 'user_photo',
        value: authData.user.fotoUrl ?? '',
      );

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
      const url = '/pengguna/daftar';
      final body = {
        'Nama_lengkap': nama,
        'Email': email,
        'Password': password,
        'Role': 'Customer',
      };

      log('--- REGISTER KE: ${_dio.options.baseUrl}$url ---');
      log('BODY: $body');

      await _dio.post(url, data: body);
      log('--- REGISTER SUCCESS ---');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw 'System Error: $e';
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/pengguna/profil');
      final data = response.data['user'];
      return UserModel.fromJson(data);
    } catch (e) {
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
    log('--- DIO ERROR ANALYSIS ---');
    log(
      'Target URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}',
    ); // Cek dia nembak ke mana
    log('Status: ${e.response?.statusCode}');
    log('Data Content: ${e.response?.data}');

    // Masalah Koneksi Fisik
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      // [PERBAIKAN] Tampilkan IP Dinamis yang dipakai Dio sekarang, BUKAN AppConstants
      return 'Gagal terhubung ke: ${_dio.options.baseUrl}.\nCek IP Laptop & WiFi.';
    }

    // Masalah Respon Server
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data['error'] ??
            data['Error'] ??
            data['message'] ??
            'Terjadi kesalahan (Map)';
      }

      if (data is List) {
        if (data.isNotEmpty) {
          return data.first.toString();
        }
        return 'Terjadi kesalahan (List Kosong)';
      }

      return data.toString();
    }

    return 'Error Tak Terduga: ${e.message}';
  }
}
