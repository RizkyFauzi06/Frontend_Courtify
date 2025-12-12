import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/owner_request_model.dart';

class AdminOwnerVerificationScreen extends ConsumerStatefulWidget {
  // 1. TAMBAHKAN VARIABLE INI AGAR BISA MENERIMA DATA 'request'
  final OwnerRequestModel request;

  const AdminOwnerVerificationScreen({
    super.key,
    required this.request, // Wajib diisi saat navigasi
  });

  @override
  ConsumerState<AdminOwnerVerificationScreen> createState() =>
      _AdminOwnerVerificationScreenState();
}

class _AdminOwnerVerificationScreenState
    extends ConsumerState<AdminOwnerVerificationScreen> {
  // Kita tidak perlu _loadData() atau FutureBuilder lagi
  // karena datanya sudah dikirim lewat 'widget.request'

  @override
  Widget build(BuildContext context) {
    // Ambil data dari parameter widget
    final item = widget.request;

    final ktpUrl = item.urlKtp != null
        ? '${AppConstants.baseUrl}/${item.urlKtp}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Verifikasi Owner"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BAGIAN FOTO KTP ---
            if (ktpUrl != null)
              GestureDetector(
                onTap: () => _showZoomImage(context, ktpUrl),
                child: Stack(
                  children: [
                    Container(
                      height: 250, // Lebih besar untuk detail page
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: NetworkImage(ktpUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Zoom KTP",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: Text("Tidak ada foto KTP")),
              ),

            // --- 2. BAGIAN DATA DETAIL ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Pemohon
                  const Text(
                    "Informasi Pemohon",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.person, "Nama Lengkap", item.nama),
                  _buildInfoRow(Icons.email, "Email", item.email),
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Tanggal Pengajuan",
                    DateFormat('dd MMM yyyy').format(item.tanggal),
                  ),

                  const Divider(height: 30, thickness: 1.5),

                  // Info Bisnis
                  const Text(
                    "Informasi Bisnis",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nama Bisnis / Lapangan",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.bisnis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Alasan Pengajuan",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.alasan,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- 3. TOMBOL AKSI ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _prosesOwner(item.idPengajuan, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text("TOLAK"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _prosesOwner(item.idPengajuan, true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("SETUJUI"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper biar rapi
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showZoomImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.1,
              maxScale: 4.0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
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

  Future<void> _prosesOwner(int idPengajuan, bool isApprove) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final repo = ref.read(adminRepositoryProvider);

      // LOGIKA REPOSITORY KAMU
      if (isApprove) {
        await repo.approveRequest(idPengajuan);
      } else {
        await repo.rejectRequest(idPengajuan);
      }

      if (mounted) {
        Navigator.pop(context); // Tutup Loading
        // Tutup Halaman Detail dan kirim sinyal 'true' (berhasil) agar halaman list me-refresh
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApprove ? "Pengajuan Disetujui!" : "Pengajuan Ditolak.",
            ),
            backgroundColor: isApprove ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
