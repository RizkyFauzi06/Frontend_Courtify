import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/booking_repository.dart';

// State Data Form
class BookingFormData {
  final DateTime? selectedDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  BookingFormData({this.selectedDate, this.startTime, this.endTime});

  BookingFormData copyWith({
    DateTime? selectedDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return BookingFormData(
      selectedDate: selectedDate ?? this.selectedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

// Controller
class BookingFormController extends StateNotifier<BookingFormData> {
  final BookingRepository _repo;

  BookingFormController(this._repo) : super(BookingFormData());

  void setDate(DateTime date) => state = state.copyWith(selectedDate: date);
  void setStartTime(TimeOfDay time) => state = state.copyWith(startTime: time);
  void setEndTime(TimeOfDay time) => state = state.copyWith(endTime: time);

  // FUNGSI UTAMA SUBMIT KE BACKEND
  Future<Map<String, dynamic>> submitBooking(int fieldId) async {
    if (state.selectedDate == null ||
        state.startTime == null ||
        state.endTime == null) {
      throw 'Mohon lengkapi tanggal dan jam.';
    }

    // Gabungkan Tanggal + Jam jadi DateTime lengkap
    final startDateTime = DateTime(
      state.selectedDate!.year,
      state.selectedDate!.month,
      state.selectedDate!.day,
      state.startTime!.hour,
      state.startTime!.minute,
    );

    final endDateTime = DateTime(
      state.selectedDate!.year,
      state.selectedDate!.month,
      state.selectedDate!.day,
      state.endTime!.hour,
      state.endTime!.minute,
    );

    // Kirim ke Repo
    return await _repo.createBooking(
      fieldId: fieldId,
      startTime: startDateTime,
      endTime: endDateTime,
    );
  }
}

// Provider
final bookingFormProvider =
    StateNotifierProvider.autoDispose<BookingFormController, BookingFormData>((
      ref,
    ) {
      final repo = ref.watch(bookingRepositoryProvider);
      return BookingFormController(repo);
    });
