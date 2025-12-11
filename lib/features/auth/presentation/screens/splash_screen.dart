import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/storage_provider.dart';

// Ubah jadi ConsumerStatefulWidget biar punya initState (Logika saat lahir)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Jalankan logika cek token setelah layar muncul
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    print('⏰ [SPLASH] Mulai hitung mundur 3 detik...');

    // Tahan 3 Detik
    await Future.delayed(const Duration(seconds: 3));
    print('✅ [SPLASH] Selesai nunggu. Sekarang cek token...');

    if (!mounted) {
      print('❌ [SPLASH] Widget sudah mati (unmounted). Batal navigasi.');
      return;
    }

    try {
      // Cek Token
      final storage = ref.read(storageProvider);

      print('🔍 [SPLASH] Sedang membaca storage...');
      final token = await storage.read(key: 'token');
      print('🔑 [SPLASH] Token ditemukan: $token');

      // Pindah Halaman
      if (token != null) {
        print('🚀 [SPLASH] Pindah ke HOME');
        if (mounted) context.go('/home');
      } else {
        print('🚀 [SPLASH] Pindah ke LOGIN');
        if (mounted) context.go('/login');
      }
    } catch (e) {
      print('🔥 [SPLASH ERROR] Gagal baca token: $e');
      // Kalau error, lempar ke Login aja biar gak stuck
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2962FF);

    return Scaffold(
      backgroundColor: Colors.white, // WAJIB PUTIH (Biar gak hitam)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO ICON
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // BRAND
            const Text(
              'COURTIFY',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 48),

            // LOADING
            const CircularProgressIndicator(color: primaryColor),
          ],
        ),
      ),
    );
  }
}
