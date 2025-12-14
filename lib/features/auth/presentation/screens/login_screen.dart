import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  void _showIpSettingsDialog() {
    final currentIp = ref.read(baseUrlProvider);
    final ipController = TextEditingController(text: currentIp);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atur IP Server"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Masukkan IP Laptop kamu.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(
                  hintText: "http://192.168.x.x:8000",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newIp = ipController.text.trim();
                if (newIp.isNotEmpty) {
                  await ref
                      .read(storageProvider)
                      .write(key: 'custom_base_url', value: newIp);
                  ref.read(baseUrlProvider.notifier).state = newIp;
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // Perform Login
      final authData = await ref
          .read(authRepositoryProvider)
          .login(_emailController.text, _passwordController.text);

      if (mounted) {
        //CHECK ROLE & REDIRECT CORRECTLY
        final role = authData.user.role.toLowerCase();

        if (role == 'admin') {
          context.go('/admin-dashboard');
        } else if (role == 'owner') {
          context.go('/owner-dashboard');
        } else {
          // Default to Customer Home
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: _showIpSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sports_soccer, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                "Courtify Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("MASUK", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text("Belum punya akun? Daftar di sini"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
