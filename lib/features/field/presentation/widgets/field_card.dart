import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Wajib import ini
import 'package:intl/intl.dart';
import 'package:frontend_futsal/shared/providers/dio_provider.dart';
import '../../data/models/field_model.dart';

class FieldCard extends ConsumerWidget {
  final FieldModel field;
  final VoidCallback onTap;

  const FieldCard({super.key, required this.field, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil warna primer dari tema Courtify
    final primaryColor = Theme.of(context).colorScheme.primary;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // LOGIKA IP DINAMIS
    // Minta alamat IP terbaru dari Provider
    final currentBaseUrl = ref.watch(baseUrlProvider);

    // Bersihkan kalau ada garis miring ganda di belakang
    final cleanBaseUrl = currentBaseUrl.endsWith('/')
        ? currentBaseUrl.substring(0, currentBaseUrl.length - 1)
        : currentBaseUrl;

    String imagePath =
        field.coverFoto; // misal: "http://localhost:8000/public/foto.jpg"
    if (imagePath.startsWith('http')) {
      imagePath = Uri.parse(imagePath).path; // jadi: "/public/foto.jpg"
    }
    // Hapus slash depan kalau double
    if (imagePath.startsWith('/') && cleanBaseUrl.endsWith('/')) {
      imagePath = imagePath.substring(1);
    } else if (!imagePath.startsWith('/') && !cleanBaseUrl.endsWith('/')) {
      imagePath = '/$imagePath';
    }

    // Rakit URL Gambar yang benar
    final imageUrl = '$cleanBaseUrl$imagePath';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Lapangan
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                field.coverFoto.isNotEmpty
                    ? imageUrl // <-- Pakai URL Dinamis tadi
                    : 'https://via.placeholder.com/400x180.png?text=COURTIFY',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        Text(
                          "Img Error",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  );
                },
              ),
            ),

            // Info Lapangan
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Lapangan
                  Text(
                    field.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tipe Lapangan
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        field.tipe,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
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
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          field.alamat,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Jam Operasional
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buka: ${field.jamBuka} - ${field.jamTutup}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Harga
                  Text(
                    '${currencyFormatter.format(field.hargaPerJam)} / Jam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
