import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_futsal/features/field/data/repositories/field_repository.dart';

// 'autoDispose' biar kalau keluar halaman, datanya di-reset
final fieldReviewsProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, int>((ref, fieldId) async {
      final repo = ref.watch(fieldRepositoryProvider);
      return repo.getReviews(fieldId);
    });
