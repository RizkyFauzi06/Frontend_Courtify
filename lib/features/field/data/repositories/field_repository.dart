import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../models/field_model.dart';
import '../models/review_model.dart';

final fieldRepositoryProvider = Provider<FieldRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FieldRepository(dio);
});

class FieldRepository {
  final Dio _dio;
  FieldRepository(this._dio);

  // GET ALL FIELDS
  Future<List<FieldModel>> getFields() async {
    try {
      final response = await _dio.get('/lapangan');
      final dynamic rawData = response.data;
      final List dataList = (rawData is Map && rawData.containsKey('data'))
          ? rawData['data']
          : rawData;

      return dataList.map((json) => FieldModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memuat daftar lapangan.';
    }
  }

  // GET DETAIL FIELD (Sesuai Backend)
  Future<FieldModel> getFieldDetail(String fieldId) async {
    try {
      final response = await _dio.get('/lapangan/$fieldId');

      // Backend: return {'data': lapanganData}
      // Jadi kita harus ambil ['data'] nya dulu
      final data = response.data['data'];

      return FieldModel.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memuat detail lapangan.';
    }
  }

  // GET REVIEWS (Sesuai Backend)
  Future<List<ReviewModel>> getReviews(String fieldId) async {
    try {
      final response = await _dio.get('/lapangan/$fieldId/ulasan');

      // Backend: return {'data': ulasanList}
      // Kita ambil ['data']
      final List dataList = response.data['data'] ?? [];

      return dataList.map((json) => ReviewModel.fromJson(json)).toList();
    } on DioException catch (e) {
      return []; // Kalau error, anggap ulasan kosong biar halaman tetap jalan
    }
  }
}
