import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // WAJIB ADA INI
import '../controllers/auth_controller.dart';
import 'register_screen.dart'; // Pastikan import ini benar
import 'package:frontend_futsal/shared/providers/storage_provider.dart';

// Ambil definisi warna
const Color courtifyPrimaryBlue = Color(0xFF2962FF);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _showIpDialog(BuildContext context, WidgetRef ref) async {
    final storage = ref.read(storageProvider);
    // Baca IP yang tersimpan sekarang (atau default)
    String? savedIp = await storage.read(key: 'custom_base_url');
    final ipCtrl = TextEditingController(
      text: savedIp ?? 'http://192.168.1.X:8080',
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfigurasi Server"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan IP Laptop Backend (Dart Frog):"),
            const SizedBox(height: 10),
            TextField(
              controller: ipCtrl,
              decoration: const InputDecoration(
                hintText: "http://192.168.x.x:8080",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // SIMPAN IP BARU KE STORAGE
              await storage.write(
                key: 'custom_base_url',
                value: ipCtrl.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Server diubah ke: ${ipCtrl.text}")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listener: Ini yang bertugas memantau hasil Login
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      // 1. Jika Gagal
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }

      // 2. Jika Sukses
      if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil! Mengalihkan...'),
            backgroundColor: Colors.green,
          ),
        );

        // >>> INI KUNCI YANG HILANG KEMARIN <<<
        // Paksa pindah ke Home Screen
        context.go('/home');
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            tooltip: 'Ganti Server IP',
            onPressed: () => _showIpDialog(context, ref), // <--- FUNGSI BARU
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Courtify
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: courtifyPrimaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: courtifyPrimaryBlue.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_soccer,
                            size: 60,
                            color: courtifyPrimaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "COURTIFY",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: courtifyPrimaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Input Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'contoh@email.com',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 20),

                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Password tidak boleh kosong' : null,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Login
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                //Panggil Login dan Tunggu Hasil Role-nya
                                final role = await ref
                                    .read(authControllerProvider.notifier)
                                    .login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );

                                // Cek Role & Pindah Halaman
                                // di dalam tombol Logi
                                if (role != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Login Berhasil!'),
                                    ),
                                  );

                                  if (role == 'Admin') {
                                    context.go('/admin-dashboard'); // KE ADMIN
                                  } else if (role == 'Owner') {
                                    context.go('/owner-dashboard'); // KE OWNER
                                  } else {
                                    context.go('/home'); // KE CUSTOMER
                                  }
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('MASUK SEKARANG'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link ke Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Gunakan context.push agar bisa kembali ke login
                          context.push('/register');
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: courtifyPrimaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
