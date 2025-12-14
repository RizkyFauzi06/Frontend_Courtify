import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'storage_provider.dart';

final baseUrlProvider = StateProvider<String>((ref) {
  return AppConstants.baseUrl; // Default awal pakai dari constants
});

final dioProvider = Provider<Dio>((ref) {
  //Kalau nilai baseUrlProvider berubah, Dio otomatis diperbarui/rebuild
  final currentBaseUrl = ref.watch(baseUrlProvider);

  final storage = ref.watch(storageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: currentBaseUrl, //  Dio sekarang ngikut provider di atas
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Cukup pasang Token saja
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
