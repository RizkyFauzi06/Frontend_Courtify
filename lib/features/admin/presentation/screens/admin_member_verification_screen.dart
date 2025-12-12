import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/member_verification_model.dart';

class AdminMemberVerificationScreen extends ConsumerStatefulWidget {
  const AdminMemberVerificationScreen({super.key});

  @override
  ConsumerState<AdminMemberVerificationScreen> createState() =>
      _AdminMemberVerificationScreenState();
}

class _AdminMemberVerificationScreenState
    extends ConsumerState<AdminMemberVerificationScreen> {
  Future<List<MemberVerificationModel>>? _futureList;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureList = ref.read(adminRepositoryProvider).getPendingMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Verifikasi Membership",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<MemberVerificationModel>>(
            future: _futureList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final list = snapshot.data ?? [];

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
                      Text("Tidak ada antrian membership."),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final buktiUrl = item.buktiUrl != null
                      ? '${AppConstants.baseUrl}/${item.buktiUrl}'
                      : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    elevation: 3, // Tambah bayangan dikit biar cantik
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- BAGIAN FOTO (DIPERBAIKI FITUR ZOOM-NYA) ---
                        if (buktiUrl != null)
                          GestureDetector(
                            onTap: () {
                              // PANGGIL FUNGSI ZOOM BARU
                              _showZoomImage(context, buktiUrl);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    image: DecorationImage(
                                      image: NetworkImage(buktiUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Overlay icon zoom biar user tau bisa diklik
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Lihat Bukti",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
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
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text("Tidak ada bukti foto"),
                            ),
                          ),

                        // --- BAGIAN TEXT ---
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.namaUser,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Paket: ${item.namaPaket}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currency.format(item.harga),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _prosesVerifikasi(item.id, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      child: const Text("TOLAK"),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _prosesVerifikasi(item.id, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("AKTIFKAN"),
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
        ),
      ],
    );
  }

  // --- FUNGSI BARU: ZOOM GAMBAR ---
  void _showZoomImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // Background transparan
        insetPadding: EdgeInsets.zero, // Full screen feel
        child: Stack(
          children: [
            // Widget agar bisa di-zoom & geser
            InteractiveViewer(
              panEnabled: true, // Bisa digeser
              minScale: 0.1,
              maxScale: 4.0, // Bisa di-zoom sampai 4x
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // Agar foto utuh terlihat
                ),
              ),
            ),
            // Tombol Close (X)
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

  Future<void> _prosesVerifikasi(int idLangganan, bool isAccepted) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await ref
          .read(adminRepositoryProvider)
          .verifyMember(idLangganan, isAccepted);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAccepted ? "Membership Diaktifkan!" : "Membership Ditolak.",
            ),
            backgroundColor: isAccepted ? Colors.green : Colors.red,
          ),
        );

        _loadData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}
