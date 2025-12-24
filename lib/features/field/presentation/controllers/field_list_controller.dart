import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_futsal/features/field/data/models/field_model.dart';
import 'package:frontend_futsal/features/field/data/repositories/field_repository.dart';

final fieldListControllerProvider =
    StateNotifierProvider<FieldListController, AsyncValue<List<FieldModel>>>((
      ref,
    ) {
      // Ambil repository dari provider sebelah
      final repository = ref.watch(fieldRepositoryProvider);
      return FieldListController(repository);
    });

// Controller Class
class FieldListController extends StateNotifier<AsyncValue<List<FieldModel>>> {
  final FieldRepository _repository;

  // Langsung panggil getFields saat controller dibuat
  FieldListController(this._repository) : super(const AsyncLoading()) {
    getFields();
  }

  Future<void> getFields() async {
    try {
      // Set status jadi Loading
      state = const AsyncLoading();

      // Ambil data dari Repo
      final fields = await _repository.getFields();

      // Jika sukses, masukkan data ke state
      state = AsyncData(fields);
    } catch (e, stackTrace) {
      // Jika error, masukkan error ke state
      state = AsyncError(e, stackTrace);
    }
  }
}
