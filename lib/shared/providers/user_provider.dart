import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider sederhana untuk menyimpan URL Foto Profil User
// Defaultnya null (artinya belum ada foto)
final userPhotoProvider = StateProvider<String?>((ref) => null);
