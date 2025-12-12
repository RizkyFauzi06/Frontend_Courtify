import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../field/data/models/field_model.dart';
import '../controllers/manage_field_controller.dart';
import 'package:frontend_futsal/shared/providers/dio_provider.dart';

class AddEditFieldScreen extends ConsumerStatefulWidget {
  final FieldModel? field; // Kalau null = Tambah Baru, Kalau ada = Edit
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fieldFormProvider);
    final isLoading = state.isLoading;

    // --- LOGIKA IP DINAMIS ---
    final currentBaseUrl = ref.watch(dioProvider).options.baseUrl;
    final cleanBaseUrl = currentBaseUrl.endsWith('/')
        ? currentBaseUrl.substring(0, currentBaseUrl.length - 1)
        : currentBaseUrl;
    // -------------------------

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
              // FOTO PICKER (DIPERBAIKI)
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) setState(() => _foto = File(picked.path));
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _buildImageDisplay(
                    cleanBaseUrl,
                  ), // Panggil Fungsi Helper
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Ketuk kotak di atas untuk ganti foto",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: "Nama Lapangan"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipe,
                items: ['Futsal', 'Mini Soccer', 'Sepak Bola']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _tipe = v!),
                decoration: const InputDecoration(labelText: "Tipe Lapangan"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga Per Jam"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatCtrl,
                decoration: const InputDecoration(labelText: "Alamat"),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiCtrl,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _rekCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Nomor Rekening"),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
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
                                  fotoPath: _foto
                                      ?.path, // Kirim foto baru (kalau ada)
                                  isEdit: widget.field != null,
                                  fieldId: widget.field?.id,
                                  noRek: _rekCtrl.text,
                                );
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("SIMPAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(String baseUrl) {
    // 1. Kalau user baru ambil foto dari galeri, tampilkan itu
    if (_foto != null) {
      return Image.file(_foto!, fit: BoxFit.cover);
    }

    // Kalau lagi EDIT dan foto lama ada, tampilkan dari server
    if (widget.field != null && widget.field!.coverFoto.isNotEmpty) {
      final imageUrl = '$baseUrl/${widget.field!.coverFoto}';
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey),
              Text("Gagal Load", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }

    // Kalau tambah baru (kosong) tampilkan icon kamera
    return const Icon(Icons.add_a_photo, size: 50, color: Colors.grey);
  }
}
