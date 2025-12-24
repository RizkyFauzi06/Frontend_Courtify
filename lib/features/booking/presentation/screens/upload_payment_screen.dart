import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Wajib import ini untuk gambar
import '../../data/repositories/booking_repository.dart';
import 'package:flutter/services.dart';

class UploadPaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String rekeningTujuan;
  const UploadPaymentScreen({
    super.key,
    required this.bookingId,
    required this.rekeningTujuan,
  });

  @override
  ConsumerState<UploadPaymentScreen> createState() =>
      _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends ConsumerState<UploadPaymentScreen> {
  File? _selectedImage;
  bool _isUploading = false;

  // Fungsi Pilih Gambar
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50,
    ); // Kompres dikit biar enteng

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi Upload
  Future<void> _upload() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final bookingIdInt = int.parse(widget.bookingId);
      // Panggil Repository
      await ref
          .read(bookingRepositoryProvider)
          .uploadPaymentProof(bookingIdInt, _selectedImage!.path);

      if (mounted) {
        // Sukses! Balik ke Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Bukti bayar berhasil dikirim! Menunggu verifikasi owner.",
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Bukti Bayar")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transfer ke:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BCA (Bank Central Asia)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.rekeningTujuan,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const Text("a.n. Futsal Kemenangan"),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: "1234567890"),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nomor rekening disalin!"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Text(
              "Silakan transfer sesuai nominal DP, lalu upload bukti transfer di sini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // AREA PREVIEW FOTO
            GestureDetector(
              onTap: () => _showPickerOption(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Ketuk untuk ambil foto"),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // TOMBOL UPLOAD
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedImage != null && !_isUploading)
                    ? _upload
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("KIRIM BUKTI BAYAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Pilih Galeri / Kamera
  void _showPickerOption() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
