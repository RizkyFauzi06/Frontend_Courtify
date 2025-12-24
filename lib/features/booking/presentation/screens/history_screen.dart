import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import '../../data/repositories/booking_repository.dart';
import 'package:frontend_futsal/features/field/presentation/controllers/field_detail_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan")),
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text("Belum ada riwayat pemesanan."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final item = bookings[index];

              // Cek Status untuk Logic Tombol
              final isUnpaid = item.status == 'menunggu_pembayaran';
              final isDone = item.status == 'lunas' || item.status == 'selesai';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Nama & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.namaLapangan,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusChip(item.status),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tanggal Main
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(item.waktuMulai),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),

                      // Footer: Harga & Tombol Aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currency.format(item.totalHarga),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),

                          // AREA TOMBOL
                          Row(
                            children: [
                              // Tombol BATAL Hanya kalau belum bayar
                              if (isUnpaid)
                                TextButton(
                                  onPressed: () async {
                                    await _cancelBooking(context, ref, item.id);
                                  },
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),

                              // Tombol BAYAR Hanya kalau belum bayar
                              if (isUnpaid)
                                ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                      '/upload-payment/${item.id}',
                                      extra: {'rekening': item.noRek},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: const Text("Bayar"),
                                ),

                              // Tombol ULASAN (Kalau sudah lunas/selesai)
                              if (isDone)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.star, size: 16),
                                  label: const Text("Ulas"),
                                  onPressed: () {
                                    _showReviewDialog(
                                      context,
                                      ref,
                                      item.fieldId,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                  ),
                                ),
                            ],
                          ),
                        ],
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

  // Widget Warna Status
  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'menunggu_pembayaran':
        color = Colors.red;
        label = "Belum Bayar";
        break;
      case 'menunggu_verifikasi':
        color = Colors.orange;
        label = "Verifikasi";
        break;
      case 'lunas':
        color = Colors.green;
        label = "Lunas";
        break;
      case 'selesai':
        color = Colors.blue;
        label = "Selesai";
        break;
      case 'dibatalkan':
        color = Colors.red;
        label = "Ditolak/Batal";
        break;
      case 'kedaluwarsa':
        color = Colors.grey;
        label = "Hangus";
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Logic Batalkan Pesanan
  Future<void> _cancelBooking(
    BuildContext context,
    WidgetRef ref,
    int bookingId,
  ) async {
    try {
      showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);

      if (context.mounted) {
        Navigator.pop(context); // Tutup Loading
        ref.refresh(historyControllerProvider); // Refresh List
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pesanan berhasil dibatalkan.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Logic Pop-up Ulasan
  void _showReviewDialog(BuildContext context, WidgetRef ref, int fieldId) {
    final commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        // Biar Dropdown bisa berubah state-nya
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Beri Ulasan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Beri rating pengalaman main kamu:"),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: rating,
                  items: [1, 2, 3, 4, 5]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Text("$e "),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => rating = val!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Rating",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: "Komentar",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                  try {
                    Navigator.pop(ctx); // Tutup dialog dulu
                    await ref
                        .read(bookingRepositoryProvider)
                        .submitReview(
                          fieldId: fieldId,
                          rating: rating,
                          comment: commentController.text,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Terima kasih ulasannya!"),
                        ),
                      );
                      ref.invalidate(
                        fieldDetailControllerProvider(fieldId.toString()),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text("Kirim"),
              ),
            ],
          );
        },
      ),
    );
  }
}
