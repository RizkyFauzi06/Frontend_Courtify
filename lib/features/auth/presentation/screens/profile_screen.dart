import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

// Pastikan import ini sesuai dengan struktur folder kamu
import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  // Fungsi Upload Foto
  Future<void> _uploadFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Kompres sedikit biar cepat
    );

    if (picked != null) {
      setState(() => _isUploading = true);

      try {
        String fileName = picked.path.split('/').last;

        // Siapkan Data
        final formData = FormData.fromMap({
          'foto': await MultipartFile.fromFile(picked.path, filename: fileName),
        });

        // Kirim ke Backend
        final response = await ref
            .read(dioProvider)
            .post('/pengguna/Foto_profil', data: formData);

        if (mounted) {
          final newUrl = response.data['url_foto'];

          // 1. Update Global State (PENTING: Biar Home Screen juga berubah)
          ref.read(userPhotoProvider.notifier).state = newUrl;

          // 2. Simpan ke Storage Lokal (Biar pas restart aplikasi tersimpan)
          await ref
              .read(storageProvider)
              .write(key: 'user_photo', value: newUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Foto berhasil diperbarui!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        String pesan = "Gagal upload.";
        if (e is DioException) {
          pesan = e.response?.data['error'] ?? "Gagal terhubung ke server.";
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(pesan), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil profil user (Nama, Email)
    final profileFuture = ref.watch(authRepositoryProvider).getUserProfile();

    // Ambil URL Foto terbaru dari Global State
    final globalPhotoUrl = ref.watch(userPhotoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: FutureBuilder<UserModel>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user =
              snapshot.data ??
              UserModel(
                id: '0',
                namaLengkap: 'User',
                email: 'email@example.com',
                role: '-',
                fotoUrl: null,
              );

          // LOGIKA PENENTUAN GAMBAR (Penting!)
          // Prioritas: 1. Global Provider (Baru upload), 2. Data dari API awal
          String? displayUrl = globalPhotoUrl ?? user.fotoUrl;

          ImageProvider? imageProvider;

          if (displayUrl != null && displayUrl.isNotEmpty) {
            // Kita tambahkan timestamp agar Cache di-refresh paksa
            // Ini solusi agar foto tidak 'stuck' di foto lama
            final urlWithBase = '${AppConstants.baseUrl}/$displayUrl';
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            imageProvider = NetworkImage('$urlWithBase?t=$timestamp');
          }

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // --- BAGIAN FOTO PROFIL ---
                  GestureDetector(
                    onTap: _isUploading ? null : _uploadFoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: imageProvider,
                          onBackgroundImageError: (_, __) {
                            // Handler kalau URL gambar error/broken
                          },
                          child: (imageProvider == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),

                        // Loading Indicator saat upload
                        if (_isUploading)
                          const Positioned.fill(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),

                        // Icon Kamera Biru
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(blurRadius: 5, color: Colors.black26),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- NAMA & EMAIL ---
                  Text(
                    user.namaLengkap,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email, style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 40),

                  // --- TOMBOL LOGOUT ---
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      // Hapus semua data login
                      await ref.read(storageProvider).deleteAll();
                      // Reset state foto
                      ref.read(userPhotoProvider.notifier).state = null;

                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
