import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../shared/providers/storage_provider.dart';
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

  // FUNGSI UPLOAD 
  Future<void> _uploadFoto() async {
    // Cek Izin Dulu 
    bool photosPermission = false;
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt >= 33) {
      var status = await Permission.photos.request();
      photosPermission = status.isGranted;
    } else {
      var status = await Permission.storage.request();
      photosPermission = status.isGranted;
    }

    if (!photosPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Butuh izin akses foto. Buka Pengaturan?"),
            action: SnackBarAction(
              label: "Buka",
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    // Buka Galeri
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => _isUploading = true);

      try {
        String fileName = picked.path.split('/').last;

        final formData = FormData.fromMap({
          'foto': await MultipartFile.fromFile(picked.path, filename: fileName),
        });

        // Request pakai Dio Otomatis pakai IP Dinamis dari DioProvider
        final response = await ref
            .read(dioProvider)
            .post('/pengguna/Foto_profil', data: formData);

        if (mounted) {
          final newUrl = response.data['url_foto'];

          // Update State
          ref.read(userPhotoProvider.notifier).state = newUrl;
          await ref.read(storageProvider).write(key: 'user_photo', value: newUrl);

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
    final profileFuture = ref.watch(authRepositoryProvider).getUserProfile();
    final globalPhotoUrl = ref.watch(userPhotoProvider);
    final currentIp = ref.watch(baseUrlProvider); 

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: FutureBuilder<UserModel>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data ??
              UserModel(
                id: '0',
                namaLengkap: 'User',
                email: 'email@example.com',
                role: '-',
                fotoUrl: null,
              );

          // LOGIKA URL DINAMIS
          String? displayUrl = globalPhotoUrl ?? user.fotoUrl;
          ImageProvider? imageProvider;

          if (displayUrl != null && displayUrl.isNotEmpty) {
            
            // Bersihkan path kalau database nyimpen 'http://localhost'
            String cleanPath = displayUrl;
            if (displayUrl.startsWith('http')) {
               // Ambil path relatifnya saja (misal: /public/uploads/foto.jpg)
               try {
                 cleanPath = Uri.parse(displayUrl).path;
               } catch (_) {}
            }
            
            // Hilangkan slash ganda di depan jika ada
            if (cleanPath.startsWith('/') && currentIp.endsWith('/')) {
              cleanPath = cleanPath.substring(1);
            } else if (!cleanPath.startsWith('/') && !currentIp.endsWith('/')) {
              cleanPath = '/$cleanPath';
            }

            // Gabungkan IP HP (currentIp) + Path Gambar
            final fullUrl = '$currentIp$cleanPath';
            
            // Tambah timestamp biar gak cache
            imageProvider = NetworkImage('$fullUrl?t=${DateTime.now().millisecondsSinceEpoch}');
            
            // Debugging: Cek terminal laptop untuk lihat URL final
            print("Loading Image: $fullUrl"); 
          }

          return Center(
            child: SingleChildScrollView(
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
                          backgroundImage: imageProvider,
                          
                          // --- BAGIAN INI YANG KITA UBAH ---
                          onBackgroundImageError: (exception, stackTrace) {
                            // 1. Print ke terminal (kalau lagi colok kabel)
                            debugPrint("Error Gambar: $exception");

                            // 2. Munculkan pesan di Layar HP (Biar kamu bisa baca errornya apa)
                            // Kita pakai Future.microtask biar aman dari error rendering
                            Future.microtask(() {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    // Tampilkan pesan error spesifik
                                    content: Text("Gagal muat gambar: $exception"),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            });
                          },
                          child: (imageProvider == null)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),

                        if (_isUploading)
                          const Positioned.fill(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),

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

                  Text(
                    user.namaLengkap,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email, style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 40),

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
                      await ref.read(storageProvider).deleteAll();
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