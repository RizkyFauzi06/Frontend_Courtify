import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/dio_provider.dart'; 
import '../../data/repositories/owner_repository.dart';
import '../controllers/dashboard_controller.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {

  // HELPER BERSIH-BERSIH URL
  String _constructDynamicUrl(String rawPath, String currentIp) {
    if (rawPath.isEmpty) return '';

    String cleanPath = rawPath;

    // Buang http://localhost
    if (rawPath.startsWith('http')) {
      try {
        cleanPath = Uri.parse(rawPath).path;
      } catch (_) {}
    }

    // Buang public/ (PENTING untuk Dart Frog)
    if (cleanPath.startsWith('/public/')) {
      cleanPath = cleanPath.substring(7);
    } else if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    // 3. Rapikan Slash
    if (cleanPath.startsWith('/') && currentIp.endsWith('/')) {
      cleanPath = cleanPath.substring(1);
    } else if (!cleanPath.startsWith('/') && !currentIp.endsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    return '$currentIp$cleanPath';
  }

  // FITUR ZOOM (Bisa dicubit/pinch)
  void _showZoomImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.1,
              maxScale: 4.0, // Zoom sampai 4x
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text("Gagal Zoom", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            // Tombol Close
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final repo = ref.watch(ownerRepositoryProvider);
    
    //AMBIL IP DINAMIS DARI LOGIN
    final currentIp = ref.watch(baseUrlProvider);

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

          final list = snapshot.data as List; 

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

              //RAKIT URL GAMBAR
              final proofUrl = _constructDynamicUrl(item.proofUrl, currentIp);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // FOTO BUKTI
                    GestureDetector(
                      onTap: () => _showZoomImage(context, proofUrl),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              proofUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    Text("Bukti Gagal Dimuat", style: TextStyle(color: Colors.grey)),
                                  ],
                                );
                              },
                            ),
                            // Overlay Icon Zoom
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text("Zoom", style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                    setState(() {}); 
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
                                    setState(() {}); 

                                    // Refresh Dashboard
                                    ref.refresh(ownerDashboardControllerProvider);
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Pembayaran Diterima!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
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