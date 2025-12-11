import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/owner_repository.dart';
import '../../../field/data/models/field_model.dart';
import '../../../../shared/providers/storage_provider.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
// Provider List Lapangan Saya
final myFieldsProvider = FutureProvider.autoDispose<List<FieldModel>>((
  ref,
) async {
  final repo = ref.watch(ownerRepositoryProvider);
  final storage = ref.watch(storageProvider);

  final query = ref.watch(searchQueryProvider);

  // Ambil ID User yang sedang Login
  final userIdStr = await storage.read(key: 'user_id');
  final myId = int.tryParse(userIdStr ?? '0') ?? 0;

  // Ambil SEMUA lapangan dari server
  final allFields = await repo.getMyFields(query: query);

  // FILTER: Hanya ambil yang ownerId-nya sama dengan ID Saya
  // Kalau ID Saya 0 (error/logout), kembalikan list kosong biar aman
  if (myId == 0) return [];

  return allFields.where((field) => field.ownerId == myId).toList();
});

// Controller Form
class FieldFormController extends StateNotifier<AsyncValue<void>> {
  final OwnerRepository _repo;
  FieldFormController(this._repo) : super(const AsyncData(null));

  Future<void> submitField({
    required String nama,
    required String tipe,
    required String alamat,
    required String harga,
    required String deskripsi,
    required String? fotoPath,
    required String noRek,
    bool isEdit = false,
    int? fieldId,
  }) async {
    state = const AsyncLoading();
    try {
      String cleanHarga = harga.replaceAll(RegExp(r'[^0-9]'), '');

      // Kalau kosong, anggap 0
      if (cleanHarga.isEmpty) cleanHarga = '0';

      final data = {
        'Nama_lapangan': nama,
        'Nomor_rekening': noRek,
        'Tipe_lapangan': tipe,
        'Alamat': alamat,
        'Harga_per_jam': int.parse(cleanHarga),
        'Deskripsi': deskripsi,
        'Jam_buka_operasional': '08:00',
        'Jam_tutup_operasional': '23:00',
        'Latitude': 0,
        'Longitude': 0,
      };

      int id = fieldId ?? 0;

      if (isEdit) {
        await _repo.updateField(id, data);
      } else {
        id = await _repo.createField(data);
      }

      // Upload Foto jika ada
      if (fotoPath != null) {
        await _repo.uploadFieldPhoto(id, fotoPath);
      }

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteField(id);
    } catch (e) {
      throw e;
    }
  }
}

final fieldFormProvider =
    StateNotifierProvider.autoDispose<FieldFormController, AsyncValue<void>>((
      ref,
    ) {
      return FieldFormController(ref.watch(ownerRepositoryProvider));
    });
