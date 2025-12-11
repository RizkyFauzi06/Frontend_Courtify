import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/field_model.dart';

class FieldCard extends StatelessWidget {
  final FieldModel field;
  final VoidCallback onTap;

  const FieldCard({super.key, required this.field, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Ambil warna primer dari tema Courtify
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Format uang jadi Rp 100.000
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // URL Gambar: Gunakan coverFoto yang sudah diparsing
    final imageUrl = '${AppConstants.baseUrl}/${field.coverFoto}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, // Naikkan elevation biar terlihat premium
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Sudut lebih melengkung
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Lapangan
            SizedBox(
              height: 180, // Tambah tinggi sedikit
              width: double.infinity,
              child: Image.network(
                field.coverFoto.isNotEmpty
                    ? imageUrl
                    : 'https://via.placeholder.com/400x180.png?text=COURTIFY',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
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
                      ), // Ikon sesuai warna Green Turf
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
