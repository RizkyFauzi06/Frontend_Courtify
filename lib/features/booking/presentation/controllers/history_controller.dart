import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_futsal/features/booking/data/models/booking_history_model.dart';
import 'package:frontend_futsal/features/booking/data/repositories/booking_repository.dart';

final historyControllerProvider =
    FutureProvider.autoDispose<List<BookingHistoryModel>>((ref) async {
      final repo = ref.watch(bookingRepositoryProvider);
      return repo.getHistory();
    });
