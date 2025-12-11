import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Ambil warna primer dari tema global (Electric Sport Blue)
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Listener: Bereaksi kalau sukses/gagal
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Akun berhasil dibuat! Silakan Login.'),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary, // Pakai Turf Green untuk sukses
          ),
        );
        Navigator.pop(context); // Balik ke Login
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun Courtify"), // Judul App Bar baru
        elevation: 0, // Hilangkan bayangan
      ),
      body: SafeArea(
        // Wajib pakai SafeArea agar tidak tertutup notch/kamera
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- BAGIAN LOGO COURTIFY ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(
                          0.1,
                        ), // Background biru muda
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 60,
                        color: primaryColor, // Ikon Biru
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BAGIAN JUDUL ---
                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nama Lengkap
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) =>
                        v!.length < 6 ? 'Password minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 32),

                  // Tombol Daftar (Otomatis Biru dari main.dart)
                  SizedBox(
                    width: double.infinity,
                    height: 55, // Biar sama tingginya dengan tombol Login
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(authControllerProvider.notifier)
                                    .register(
                                      _namaController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                              }
                            },
                      // Menghapus: backgroundColor: Colors.green, -> Sekarang diatur global di main.dart
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text('DAFTAR SEKARANG'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Link Kembali ke Login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sudah punya akun? Masuk',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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
