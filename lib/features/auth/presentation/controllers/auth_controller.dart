import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncData(null));

  // Fungsi Login
  Future<String?> login(String email, String password) async {
    state = const AsyncLoading(); // Mulai Loading
    try {
      // Panggil Repo
      final response = await _repository.login(email, password);

      state = const AsyncData(null); // Stop Loading (Sukses)

      // KEMBALIKAN ROLE (Contoh: 'Owner' atau 'Customer')
      return response.user.role;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace); // Stop Loading (Error)
      return null; // Gagal, kembalikan null
    }
  }

  // Fungsi Register
  Future<void> register(String nama, String email, String password) async {
    state = const AsyncLoading();
    try {
      // Panggil repository untuk tembak API Register
      await _repository.register(nama, email, password);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
