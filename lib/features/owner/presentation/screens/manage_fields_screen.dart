import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../controllers/manage_field_controller.dart';
import 'add_edit_field_screen.dart';

class ManageFieldsScreen extends ConsumerStatefulWidget {
  const ManageFieldsScreen({super.key});

  @override
  ConsumerState<ManageFieldsScreen> createState() => _ManageFieldsScreenState();
}

class _ManageFieldsScreenState extends ConsumerState<ManageFieldsScreen> {
  String _searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // HELPER BERSIH-BERSIH URL
  String _constructDynamicUrl(String rawPath, String currentIp) {
    if (rawPath.isEmpty) return '';

    String cleanPath = rawPath;
    if (rawPath.startsWith('http')) {
      try {
        cleanPath = Uri.parse(rawPath).path;
      } catch (_) {}
    }

    // Buang kata 'public/' (Dart Frog Issue)
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

    // Gabung
    return '$currentIp$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data lapangan
    final fieldsAsync = ref.watch(myFieldsProvider);

    // AMBIL IP DINAMIS
    final currentIp = ref.watch(baseUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Lapangan Saya")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditFieldScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Cari Nama atau No Rek...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = "";
                            _searchCtrl.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // LIST LAPANGAN
          Expanded(
            child: fieldsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (fields) {
                // LOGIKA FILTER
                final filteredFields = fields.where((field) {
                  final query = _searchQuery.toLowerCase();
                  final nama = field.nama.toLowerCase();
                  final rek = field.nomorRekening.toLowerCase();
                  return nama.contains(query) || rek.contains(query);
                }).toList();

                if (filteredFields.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Belum ada lapangan."),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filteredFields.length,
                  itemBuilder: (context, index) {
                    final field = filteredFields[index];

                    // RAKIT URL GAMBAR DENGAN FUNGSI BARU
                    final imageUrl = _constructDynamicUrl(
                      field.coverFoto,
                      currentIp,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        // FOTO LAPANGAN
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: field.coverFoto.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) {
                                    debugPrint(
                                      "Err Lapangan: $imageUrl -> $err",
                                    );
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.sports_soccer),
                                ),
                        ),

                        // INFO LAPANGAN
                        title: Text(
                          field.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.tipe),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Rek: ${field.nomorRekening}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,

                        // TOMBOL AKSI
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditFieldScreen(field: field),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Hapus Lapangan?"),
                                    content: const Text(
                                      "Data yang dihapus tidak bisa dikembalikan.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Batal"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          "Hapus",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await ref
                                      .read(fieldFormProvider.notifier)
                                      .delete(field.id);
                                  ref.refresh(myFieldsProvider); // Refresh UI
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
