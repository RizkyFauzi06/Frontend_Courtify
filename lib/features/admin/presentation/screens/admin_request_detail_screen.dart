import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:frontend_futsal/features/admin/data/models/owner_request_model.dart';
import 'package:frontend_futsal/features/admin/data/repositories/admin_repository.dart';

class AdminRequestDetailScreen extends ConsumerWidget {
  final OwnerRequestModel request; // Terima data dari list

  const AdminRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pengajuan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO KTP
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: request.urlKtp != null
                  ? Image.network(
                      '${AppConstants.baseUrl}/${request.urlKtp}',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.broken_image, size: 50),
                    )
                  : const Center(child: Text("Tidak ada foto KTP")),
            ),
            const SizedBox(height: 24),

            // INFO
            _infoRow("Nama User", request.nama),
            _infoRow("Email", request.email),
            const Divider(),
            _infoRow("Nama Bisnis", request.bisnis),
            const SizedBox(height: 8),
            const Text(
              "Alasan Pengajuan:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Text(request.alasan, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 40),

            // TOMBOL AKSI
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(adminRepositoryProvider)
                          .rejectRequest(request.idPengajuan);
                      if (context.mounted) {
                        context.pop(); // Balik ke List
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ditolak.")),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("TOLAK"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(adminRepositoryProvider)
                          .approveRequest(request.idPengajuan);
                      if (context.mounted) {
                        context.pop(); // Balik ke List
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Disetujui!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
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
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
