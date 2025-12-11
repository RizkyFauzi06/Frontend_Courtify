import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../data/repositories/membership_repository.dart';
import '../controllers/membership_controller.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipList = ref.watch(membershipListProvider);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    //TRANSAKSI & UPLOAD
    Future<void> _prosesTransaksi(int idPaket, double harga) async {
      try {
        // SUBSCRIBE DULU (Daftar di DB)
        print('--- [DEBUG] 1. Mencoba Subscribe ID: $idPaket ---');

        // Tampilkan Loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        // Panggil Repository (Pastikan URL di repo benar '/membership')
        await ref.read(membershipRepositoryProvider).subscribe(idPaket);

        print('--- [DEBUG] 1. Subscribe Sukses! ---');
        if (context.mounted) Navigator.pop(context); // Tutup Loading

        //TAMPILKAN DIALOG REKENING
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Transfer Pembayaran"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Transfer ke Admin:"),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.shade50,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BCA",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "8888-9999-0000",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Wajib upload bukti transfer agar diproses."),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    //Upload
                    _pickAndUpload(context, ref);
                  },
                  child: const Text("Upload Bukti"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print('--- [ERROR] Subscribe Gagal: $e ---');
        if (context.mounted) {
          Navigator.pop(context); // Tutup loading kalau error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Membership")),
      body: membershipList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (plans) {
          if (plans.isEmpty) return const Center(child: Text("Paket kosong."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];

              Color cardColor = Colors.white;
              if (plan.nama.toLowerCase().contains('gold'))
                cardColor = const Color(
                  0xFFFFD700,
                ).withOpacity(0.2); // Emas Muda
              else if (plan.nama.toLowerCase().contains('silver'))
                cardColor = const Color(
                  0xFFC0C0C0,
                ).withOpacity(0.3); // Perak Muda
              else if (plan.nama.toLowerCase().contains('bronze'))
                cardColor = const Color(
                  0xFFCD7F32,
                ).withOpacity(0.3); // Perunggu Muda
              // ------------------------------
              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        plan.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${plan.diskon}% Diskon",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text(
                        "${currency.format(plan.harga)} / Bulan",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _prosesTransaksi(plan.id, plan.harga),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("GABUNG SEKARANG"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // UPLOAD BUKTI
  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      try {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        // AMBIL NAMA FILE MANUAL (Anti 400)
        String fileName = picked.path.split('/').last;

        print('--- [DEBUG] 3. Mulai Upload ---');
        print('File: $fileName');
        print('Target URL: /membership/upload');

        // SIAPKAN DATA
        final formData = FormData.fromMap({
          'bukti': await MultipartFile.fromFile(
            picked.path,
            filename: fileName,
          ), // Key 'bukti' sesuai backend
        });

        // TEMBAK LANGSUNG
        await ref.read(dioProvider).post('/membership/upload', data: formData);

        print('--- [DEBUG] Upload Sukses! ---');

        if (context.mounted) {
          Navigator.pop(context); // Tutup Loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bukti terkirim! Tunggu Admin."),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Keluar
        }
      } catch (e) {
        print('--- [ERROR] Upload Gagal: $e ---');
        if (context.mounted) {
          Navigator.pop(context);
          String err = "Gagal Upload.";
          if (e is DioException)
            err =
                e.response?.data['error'] ?? "Error ${e.response?.statusCode}";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
