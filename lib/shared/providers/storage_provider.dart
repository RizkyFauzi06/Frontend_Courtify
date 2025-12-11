import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Provider ini tugasnya sederhana: Menyediakan akses ke penyimpanan HP
final storageProvider = Provider<FlutterSecureStorage>((ref) {
  // Opsi tambahan agar aman di Android (encrypted shared preferences)
  AndroidOptions getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  return FlutterSecureStorage(aOptions: getAndroidOptions());
});
