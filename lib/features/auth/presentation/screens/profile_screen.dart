import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
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
  File? _newPhoto;
  bool _isUploading = false;
  String? _photoUrlServer;

  // Upload Foto dengan Filename Manual (Anti Error 400)
  Future<void> _uploadFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => _isUploading = true); // Loading mulai

      try {
        String fileName = picked.path.split('/').last;
        print('--- DEBUG UPLOAD PROFIL ---');
        print('File: $fileName');
        print('Target URL: /pengguna/ganti_foto');

        final formData = FormData.fromMap({
          'foto': await MultipartFile.fromFile(picked.path, filename: fileName),
        });

        // CEK URL INI: Apakah file backend 'routes/pengguna/ganti_foto.dart' ADA?
        final response = await ref
            .read(dioProvider)
            .post('/pengguna/Foto_profil', data: formData);

        print('--- SUKSES: ${response.statusCode} ---');

        if (mounted) {
          final newUrl = response.data['url_foto'];
          ref.read(userPhotoProvider.notifier).state = newUrl;
          await ref
              .read(storageProvider)
              .write(key: 'user_photo', value: newUrl);

          setState(() {
            _newPhoto = null;
            _photoUrlServer = newUrl; // Update UI langsung
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sukses!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('--- ERROR UPLOAD: $e ---'); // LIHAT TERMINAL!

        String pesan = "Gagal upload.";
        if (e is DioException) {
          // Kalau 404 -> Berarti nama file backend SALAH / Belum dibuat
          if (e.response?.statusCode == 404) {
            pesan =
                "Error 404: URL '/pengguna/ganti_foto' tidak ditemukan. Cek nama file backend!";
          } else {
            pesan = e.response?.data['error'] ?? e.message ?? "Error Server";
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(pesan), backgroundColor: Colors.red),
          );
          setState(() => _newPhoto = null);
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileFuture = ref.watch(authRepositoryProvider).getUserProfile();

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
                namaLengkap: 'Error',
                email: 'Error',
                role: '-',
              );

          // Sinkronisasi Foto ke Home Screen
          if (user.fotoUrl != null) {
            Future.microtask(
              () => ref.read(userPhotoProvider.notifier).state = user.fotoUrl,
            );
          }

          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _isUploading ? null : _uploadFoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _newPhoto != null
                            ? FileImage(_newPhoto!) as ImageProvider
                            : (user.fotoUrl != null
                                  ? NetworkImage(
                                      '${AppConstants.baseUrl}/${user.fotoUrl}',
                                    )
                                  : null),
                        child: (_newPhoto == null && user.fotoUrl == null)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      if (_isUploading) const CircularProgressIndicator(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
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

                // DATA DIRI
                Text(
                  user.namaLengkap,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ), // <-- Cek ini

                const SizedBox(height: 40),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await ref.read(storageProvider).deleteAll();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
