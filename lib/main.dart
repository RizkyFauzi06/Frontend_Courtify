import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // Untuk Format Rupiah/Tanggal
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal/rupiah Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(
    // WAJIB ADA PROVIDER SCOPE BIAR RIVERPOD JALAN
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Panggil router provider yang sudah kita perbaiki
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Courtify Futsal',
      debugShowCheckedModeBanner: false,

      // TEMA GLOBAL (Biar warna konsisten Biru/Kuning/dll)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Warna Utama Aplikasi
          primary: Colors.blue,
        ),
        useMaterial3: true,

        // Atur Header App Bar jadi Biru
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),

        // [TAMBAHAN BARU] Atur Tombol jadi Biru otomatis
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      routerConfig: router,
    );
  }
}
