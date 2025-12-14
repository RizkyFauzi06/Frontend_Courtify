import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/field_repository.dart';

// FutureProvider.family artinya Provider ini butuh input (fieldId)
final fieldDetailControllerProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, fieldId) async {
      // Ambil repository
      final repo = ref.watch(fieldRepositoryProvider);

      // Panggil 2 fungsi API secara paralel (Detail Lapangan)
      final fieldFuture = repo.getFieldDetail(fieldId);

      // Tunggu keduanya selesai
      final field = await fieldFuture;

      // Kembalikan hasilnya dalam satu paket (Map)
      return {'field': field};
    });
