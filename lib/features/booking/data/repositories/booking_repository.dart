import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/booking_history_model.dart';

final bookingRepositoryProvider = Provider(
  (ref) => BookingRepository(ref.watch(dioProvider)),
);

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  // FUNGSI BOOKING
  Future<Map<String, dynamic>> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final url = '/pemesanan';
      final body = {
        'Id_lapangan': fieldId,
        'Waktu_mulai': startTime.toIso8601String(),
        'Waktu_selesai': endTime.toIso8601String(),
      };

      log('--- BOOKING REQUEST ---');
      log('BODY: $body');

      final response = await _dio.post(url, data: body);

      log('--- BOOKING SUCCESS ---');
      return response.data;
    } on DioException catch (e) {
      String msg = 'Gagal Booking.';
      if (e.response != null) {
        msg =
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Error Server';
      }
      throw msg;
    }
  }

  //  FUNGSI UPLOAD BUKTI BAYAR
  Future<void> uploadPaymentProof(int bookingId, String filePath) async {
    try {
      // URL Dinamis sesuai folder backend: routes/pemesanan/[id]/upload_bukti.dart
      final url = '/pemesanan/$bookingId/upload_bukti';

      final formData = FormData.fromMap({
        'bukti': await MultipartFile.fromFile(filePath),
      });

      log('--- UPLOAD REQUEST ---');
      log('URL: ${AppConstants.baseUrl}$url');

      await _dio.post(url, data: formData);
      log('--- UPLOAD SUCCESS ---');
    } on DioException catch (e) {
      String msg = 'Gagal Upload.';
      if (e.response != null) {
        msg =
            e.response?.data['error'] ??
            e.response?.data['message'] ??
            'Error Server';
      }
      throw msg;
    }
  }

  //  FUNGSI GET HISTORY
  Future<List<BookingHistoryModel>> getHistory() async {
    try {
      final response = await _dio.get('/pemesanan');

      final dynamic rawData = response.data;
      log('--- CHECK HISTORY DATA: ${rawData.runtimeType} ---');

      List listData = [];

      // Cek apakah Map atau List
      if (rawData is Map<String, dynamic>) {
        listData = rawData['data'] ?? [];
      } else if (rawData is List) {
        listData = rawData;
      }

      return listData
          .map((json) => BookingHistoryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      log('Dio Error: ${e.response?.statusCode}');
      return [];
    } catch (e) {
      log('Parsing Error: $e');
      return [];
    }
  }

  // FUNGSI BATALKAN PESANAN
  Future<void> cancelBooking(int bookingId) async {
    try {
      final url = '/pemesanan/$bookingId/batal';

      // GANTI DARI .put MENJADI .post
      await _dio.post(url);

      log('--- CANCEL SUCCESS ---');
    } on DioException catch (e) {
      String msg = 'Gagal membatalkan.';
      if (e.response != null) {
        msg = e.response?.data['error'] ?? 'Error Server';
      }
      throw msg;
    }
  }

  Future<void> submitReview({
    required int fieldId,
    required int rating,
    required String comment,
  }) async {
    try {
      final url = '/ulasan';

      // Body JSON Sesuai Backend Kamu (PascalCase)
      final body = {
        'Id_lapangan': fieldId,
        'Rating': rating,
        'Komentar': comment,
      };

      await _dio.post(url, data: body);
      log('--- REVIEW SUCCESS ---');
    } on DioException catch (e) {
      String msg = 'Gagal kirim ulasan.';
      if (e.response != null) {
        msg = e.response?.data['error'] ?? 'Error Server';
      }
      throw msg;
    }
  }
}
