import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../field/data/models/field_model.dart';
import '../controllers/manage_field_controller.dart';
import 'package:frontend_futsal/shared/providers/dio_provider.dart';

class AddEditFieldScreen extends ConsumerStatefulWidget {
  final FieldModel? field; 
  const AddEditFieldScreen({super.key, this.field});

  @override
  ConsumerState<AddEditFieldScreen> createState() => _AddEditFieldScreenState();
}

class _AddEditFieldScreenState extends ConsumerState<AddEditFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _deskripsiCtrl;
  late TextEditingController _rekCtrl;
  String _tipe = 'Futsal';
  File? _foto;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.field?.nama ?? '');
    _hargaCtrl = TextEditingController(
      text: widget.field?.hargaPerJam.toString() ?? '',
    );
    _alamatCtrl = TextEditingController(text: widget.field?.alamat ?? '');
    _deskripsiCtrl = TextEditingController(text: widget.field?.deskripsi ?? '');
    _rekCtrl = TextEditingController(text: widget.field?.nomorRekening ?? '');
    if (widget.field != null) _tipe = widget.field!.tipe;
  }

  //HELPER BERSIH-BERSIH URL 
  String _constructDynamicUrl(String rawPath, String currentIp) {
    if (rawPath.isEmpty) return '';

    String cleanPath = rawPath;

    // Buang http://localhost
    if (rawPath.startsWith('http')) {
      try {
        cleanPath = Uri.parse(rawPath).path;
      } catch (_) {}
    }

    // Buang public/
    if (cleanPath.startsWith('/public/')) {
      cleanPath = cleanPath.substring(7);
    } else if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    // Rapikan Slash
    if (cleanPath.startsWith('/') && currentIp.endsWith('/')) {
      cleanPath = cleanPath.substring(1);
    } else if (!cleanPath.startsWith('/') && !currentIp.endsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    return '$currentIp$cleanPath';
  }

  //FUNGSI PILIH FOTO AMAN (Check Permission)
  Future<void> _pickImageSafe() async {
    // Cek Izin dulu
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
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, //kompres
    );
    if (picked != null) {
      setState(() => _foto = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldFormProvider);
    final isLoading = state.isLoading;

    // MBIL IP DINAMIS YANG BENAR
    final currentIp = ref.watch(baseUrlProvider);

    ref.listen(fieldFormProvider, (prev, next) {
      if (next is AsyncData && !next.isLoading) {
        Navigator.pop(context); // Tutup Form
        ref.refresh(myFieldsProvider); // Refresh List
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil disimpan!")));
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field == null ? "Tambah Lapangan" : "Edit Lapangan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO PICKER
              GestureDetector(
                onTap: _pickImageSafe,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImageDisplay(
                    currentIp,
                  ), // Kirim IP ke fungsi display
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Ketuk kotak di atas untuk ganti foto",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama Lapangan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stadium),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipe,
                items: ['Futsal', 'Mini Soccer', 'Sepak Bola']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _tipe = v!),
                decoration: const InputDecoration(
                  labelText: "Tipe Lapangan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Per Jam",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: "IDR",
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatCtrl,
                decoration: const InputDecoration(
                  labelText: "Alamat",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiCtrl,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _rekCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nomor Rekening",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(fieldFormProvider.notifier)
                                .submitField(
                                  nama: _namaCtrl.text,
                                  tipe: _tipe,
                                  alamat: _alamatCtrl.text,
                                  harga: _hargaCtrl.text,
                                  deskripsi: _deskripsiCtrl.text,
                                  fotoPath: _foto?.path,
                                  isEdit: widget.field != null,
                                  fieldId: widget.field?.id,
                                  noRek: _rekCtrl.text,
                                );
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIMPAN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(String currentIp) {
    // Kalau user baru ambil foto dari galeri
    if (_foto != null) {
      return Image.file(_foto!, fit: BoxFit.cover);
    }

    // Kalau lagi EDIT dan foto lama ada (Dari Server)
    if (widget.field != null && widget.field!.coverFoto.isNotEmpty) {
      // RAKIT URL DINAMIS
      final imageUrl = _constructDynamicUrl(widget.field!.coverFoto, currentIp);

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (ctx, err, stack) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 40),
              SizedBox(height: 4),
              Text("Gagal Load Foto", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Kalau tambah baru
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text("Tambah Foto", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}