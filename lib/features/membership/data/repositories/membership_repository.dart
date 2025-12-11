import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../models/membership_model.dart';

final membershipRepositoryProvider = Provider(
  (ref) => MembershipRepository(ref.watch(dioProvider)),
);

class MembershipRepository {
  final Dio _dio;
  MembershipRepository(this._dio);

  // GET MEMBERSHIP LIST
  Future<List<MembershipModel>> getMemberships() async {
    try {
      final response = await _dio.get('/membership');

      // Backend return: {'data': [...]}
      final List data = response.data['data'] ?? [];

      return data.map((e) => MembershipModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memuat paket.';
    }
  }

  // SUBSCRIBE (POST)
  Future<void> subscribe(int idTingkatan) async {
    try {
      const url = '/membership';

      final body = {'Id_tingkatan': idTingkatan}; // Key sesuai backend

      await _dio.post(url, data: body);
    } on DioException catch (e) {
      String msg = 'Gagal berlangganan.';
      if (e.response != null) {
        msg =
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Error Server';
      }
      throw msg;
    }
  }
}
