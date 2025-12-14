import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../controllers/review_controller.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../data/models/field_model.dart';

class FieldDetailScreen extends ConsumerStatefulWidget {
  final FieldModel field;

  const FieldDetailScreen({super.key, required this.field});

  @override
  ConsumerState<FieldDetailScreen> createState() => _FieldDetailScreenState();
}

class _FieldDetailScreenState extends ConsumerState<FieldDetailScreen> {
  // HELPER PEMBERSIH URL
  String _constructDynamicUrl(String rawPath, String currentIp) {
    if (rawPath.isEmpty) return '';
    String cleanPath = rawPath;

    if (rawPath.startsWith('http')) {
      try {
        cleanPath = Uri.parse(rawPath).path;
      } catch (_) {}
    }
    if (cleanPath.startsWith('/public/')) {
      cleanPath = cleanPath.substring(7);
    } else if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }
    if (cleanPath.startsWith('/') && currentIp.endsWith('/')) {
      cleanPath = cleanPath.substring(1);
    } else if (!cleanPath.startsWith('/') && !currentIp.endsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    return '$currentIp$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final currentIp = ref.watch(baseUrlProvider);
    final imageUrl = _constructDynamicUrl(field.coverFoto, currentIp);
    final reviewsAsync = ref.watch(fieldReviewsProvider(field.id));

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. HEADER GAMBAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: field.coverFoto.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  )
                : Container(color: Colors.blueAccent),
          ),

          // 2. TOMBOL BACK
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // 3. KONTEN DETAIL (Scrollable)
          Positioned.fill(
            top: 250,
            child: Container(
              // Padding bawah 80 biar konten paling bawah gak ketutup tombol Booking
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: SingleChildScrollView(
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          currency.format(field.hargaPerJam),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Lokasi
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 18,
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
                    const SizedBox(height: 16),

                    // Deskripsi
                    const Text(
                      "Deskripsi",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      field.deskripsi.isEmpty
                          ? "Tidak ada deskripsi."
                          : field.deskripsi,
                      style: const TextStyle(height: 1.5),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),

                    // Ulasan Pengguna
                    const Text(
                      "Ulasan Pengguna",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    reviewsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text(
                        "Gagal memuat ulasan.",
                        style: const TextStyle(color: Colors.red),
                      ),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text("Belum ada ulasan untuk lapangan ini."),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            
                            // Parsing Data Aman
                            final namaUser = review['Nama_lengkap'] ??
                                review['nama_lengkap'] ??
                                'Pengguna';
                                
                            final rawRating =
                                review['Rating'] ?? review['rating'] ?? 5;
                            final rating =
                                num.tryParse(rawRating.toString())?.toInt() ?? 5;
                                
                            final komentar =
                                review['Komentar'] ?? review['komentar'] ?? '-';
                                
                            final fotoUrl = review['Foto_pengguna'];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: (fotoUrl != null &&
                                        fotoUrl.toString().isNotEmpty)
                                    ? NetworkImage(
                                        _constructDynamicUrl(fotoUrl, currentIp))
                                    : null,
                                child: (fotoUrl == null ||
                                        fotoUrl.toString().isEmpty)
                                    ? Text(
                                        namaUser[0].toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    namaUser,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.orange),
                                  Text(
                                    " $rating.0",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: Text(komentar),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. TOMBOL BOOKING (Melayang di Bawah)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      '/booking/${field.id}',
                      extra: {
                        'name': field.nama,
                        'price': field.hargaPerJam,
                      },
                    );
                  },
                  child: const Text(
                    "BOOKING SEKARANG",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}