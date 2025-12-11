import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // Import Router
import '../../../../core/constants/app_constants.dart';
import '../controllers/field_detail_controller.dart';
import 'package:frontend_futsal/features/field/data/models/field_model.dart';
import 'package:frontend_futsal/features/field/data/models/review_model.dart';

class FieldDetailScreen extends ConsumerWidget {
  final String fieldId;
  const FieldDetailScreen({super.key, required this.fieldId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(fieldDetailControllerProvider(fieldId));
    final primaryColor = Theme.of(context).colorScheme.primary;
    return detailState.when(
      // Tampilan Loading
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // Tampilan Error
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text('Gagal memuat: $err')),
      ),

      // Tampilan Sukses
      data: (data) {
        final field = data['field'] as FieldModel;
        final reviews = data['reviews'] as List<ReviewModel>;

        final currency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );
        final imageUrl = '${AppConstants.baseUrl}/${field.coverFoto}';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // TOMBOL BOOKING
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigasi ke Booking Screen dengan Data
                context.push(
                  '/booking/${field.id}',
                  extra: {
                    'name': field.nama,
                    'price': field.hargaPerJam.toInt(), // Pastikan int
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: primaryColor,
              ),
              child: const Text(
                'BOOKING SEKARANG',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          body: CustomScrollView(
            slivers: [
              // Header Gambar
              SliverAppBar(
                expandedHeight: 280,
                pinned: false,
                backgroundColor: primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.sports_soccer,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),

              // Konten Detail
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Harga
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              field.nama,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            currency.format(field.hargaPerJam),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Alamat
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              field.alamat,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        field.deskripsi.isEmpty
                            ? "Tidak ada deskripsi."
                            : field.deskripsi,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Ulasan
                      const Text(
                        "Ulasan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      reviews.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("Belum ada ulasan."),
                              ),
                            )
                          : Column(
                              children: reviews
                                  .map(
                                    (review) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          review.namaPengguna.isNotEmpty
                                              ? review.namaPengguna[0]
                                              : '?',
                                        ),
                                      ),
                                      title: Text(
                                        review.namaPengguna,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(review.komentar),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          Text(review.rating.toString()),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
