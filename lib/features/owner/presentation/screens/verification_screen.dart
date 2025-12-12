import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend_futsal/shared/providers/dio_provider.dart';
import '../../data/repositories/owner_repository.dart';
import '../controllers/dashboard_controller.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final repo = ref.watch(ownerRepositoryProvider);

    String getDynamicImageUrl(String path) {
      final currentBaseUrl = ref.watch(dioProvider).options.baseUrl;
      final cleanBaseUrl = currentBaseUrl.endsWith('/')
          ? currentBaseUrl.substring(0, currentBaseUrl.length - 1)
          : currentBaseUrl;
      return '$cleanBaseUrl/$path';
    }
    // ----------------------------------

    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Pembayaran")),
      body: FutureBuilder(
        future: repo.getPendingVerifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data as List; // List<VerificationModel>

          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text("Semua aman! Tidak ada antrian verifikasi."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              // Rakit URL Gambar Bukti Bayar pakai fungsi tadi
              final proofUrl = getDynamicImageUrl(item.proofUrl);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // FOTO BUKTI (Klik untuk Zoom)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Image.network(
                              proofUrl, // <-- Pakai URL Dinamis
                              errorBuilder: (ctx, err, stack) => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text("Gagal memuat gambar"),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Image.network(
                          proofUrl, // <-- Pakai URL Dinamis
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "Bukti Bayar Error",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null)
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  child,
                                  // Icon Zoom biar user tau bisa diklik
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Booking: ${item.fieldName}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Transfer: ${currency.format(item.total)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // TOMBOL TOLAK
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await repo.verifyPayment(item.id, false);
                                    setState(() {}); // Refresh list
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Tolak"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // TOMBOL TERIMA
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await repo.verifyPayment(item.id, true);
                                    setState(() {}); // Refresh list

                                    // Refresh Dashboard juga biar angkanya nambah
                                    ref.refresh(
                                      ownerDashboardControllerProvider,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Pembayaran Diterima!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("TERIMA"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
