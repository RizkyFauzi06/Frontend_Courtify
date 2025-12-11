import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../shared/providers/dio_provider.dart';

class OwnerRequestScreen extends ConsumerStatefulWidget {
  const OwnerRequestScreen({super.key});

  @override
  ConsumerState<OwnerRequestScreen> createState() => _OwnerRequestScreenState();
}

class _OwnerRequestScreenState extends ConsumerState<OwnerRequestScreen> {
  final _bisnisCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();
  File? _ktpImage;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_bisnisCtrl.text.isEmpty ||
        _alasanCtrl.text.isEmpty ||
        _ktpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi data & foto KTP!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'Nama_bisnis': _bisnisCtrl.text,
        'Alasan': _alasanCtrl.text,
        'foto_ktp': await MultipartFile.fromFile(_ktpImage!.path),
      });

      await ref
          .read(dioProvider)
          .post('/pengguna/ajukan_owner', data: formData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Berhasil"),
            content: const Text(
              "Pengajuan dikirim. Admin akan memverifikasi data Anda.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = "Gagal mengajukan.";
        if (e is DioException) msg = e.response?.data['error'] ?? msg;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Jadi Partner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Bergabunglah sebagai Owner Courtify!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Verifikasi identitas diperlukan untuk keamanan.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _bisnisCtrl,
              decoration: const InputDecoration(
                labelText: "Nama Usaha / Lapangan",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alasanCtrl,
              decoration: const InputDecoration(
                labelText: "Alasan / Deskripsi Singkat",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            const Text(
              "Upload Selfie dengan KTP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                ); // Langsung Kamera biar real
                if (picked != null)
                  setState(() => _ktpImage = File(picked.path));
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _ktpImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_front,
                            size: 50,
                            color: Colors.grey,
                          ),
                          Text("Ketuk untuk ambil foto"),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_ktpImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("KIRIM PENGAJUAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
