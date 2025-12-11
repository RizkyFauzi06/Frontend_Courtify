import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'storage_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  // ngeprovide dio ke variabel dioProvider
  final storage = ref.watch(
    storageProvider,
  ); //membaca storage provider untuk mengambil dan
  // membaca data juga menyimpan

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl, //base url di folder constant
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type':
            'application/json', //header atau request akan berbentuk JSON
        'Accept': 'application/json',
      },
    ), //konfigurasi dasar rio atau menentukan isi dio apa aja
  );

  dio.interceptors.add(
    // kode yang jalan setiap request
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // CEK IP CUSTOM DARI STORAGE
        // simpan IP custom dengan key 'custom_base_url'
        final customIp = await storage.read(key: 'custom_base_url');

        if (customIp != null && customIp.isNotEmpty) {
          // GANTI BASE URL SECARA DINAMIS
          options.baseUrl = customIp;
        }

        // PASANG TOKEN
        final token = await storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ),
  );

  return dio;
});
