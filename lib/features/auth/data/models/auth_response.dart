import 'user.dart';

class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Ambil Token Kalau null, ganti string kosong biar gak crash
    final tokenData = json['token']?.toString() ?? '';

    // Cek apakah ada data user?
    var userData = json['user'] ?? json['data'];

    // Kalau userData itu NULL, kita buat User Dummy.
    // biar BISA MASUK HOME dulu.
    if (userData == null || userData is! Map<String, dynamic>) {
      return AuthResponseModel(
        token: tokenData,
        user: UserModel(
          id: '0',
          namaLengkap: 'Pengguna (Data Null)',
          email: '-',
          role: 'Customer', // Default role biar menu muncul
          fotoUrl: '',
        ),
      );
    }

    // Kalau data user ada beneran, baru diparsing normal
    return AuthResponseModel(
      token: tokenData,
      user: UserModel.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
