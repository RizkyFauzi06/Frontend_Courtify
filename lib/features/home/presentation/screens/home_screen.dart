import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart'; // Import Dio buat request upgrade
import '../../../../shared/providers/storage_provider.dart';
import '../../../../shared/providers/dio_provider.dart'; // Import Provider Dio
import '../../../field/presentation/controllers/field_list_controller.dart';
import '../../../field/presentation/widgets/field_card.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../core/constants/app_constants.dart'; // Buat Base URL

class HomeScreen extends ConsumerStatefulWidget {
  // bikin class yang ada sifat customer widget nya
  const HomeScreen({
    super.key,
  }); // const ini agar widget nya ngak terus terus di build
  // super.key ini super untuk mengakses parent class yaitu consumerstate... dan key itu apa yang di aksesnya

  @override // memberi tahu bahwa aku merubah  class cunsumer state method nya
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // membuat objek state untuk widget ini
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = "";
  String _selectedFilter = "Semua";
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filterOptions = [
    "Semua",
    "Termurah",
    "Termahal",
    "Futsal",
    "Mini Soccer",
    "Sepak Bola",
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // fungsi yang dipanggil setiap ada perubahan
    final fieldListState = ref.watch(fieldListControllerProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // tempat membuat ui dll
      appBar: AppBar(
        title: const Text(
          "Courtify",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          // TOMBOL UPGRADE
          IconButton(
            icon: const Icon(Icons.upgrade),
            tooltip: 'Jadi Owner',
            onPressed: () {
              // Langsung pindah ke halaman form upload KTP
              context.push('/owner-request');
            },
          ),
          // TOMBOL HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'), // kehalaman history
          ),
          //TOMBOL MEMBERSHIP
          IconButton(
            icon: const Icon(Icons.card_membership),
            onPressed: () => context.push('/membership'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Consumer(
                // Bungkus pake Consumer biar bisa nge-watch
                builder: (context, ref, child) {
                  // DENGARKAN PERUBAHAN FOTO
                  final photoUrl = ref.watch(
                    userPhotoProvider,
                  ); //membaca dengan riverfod

                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                    // Logika: Kalau ada URL di provider -> Tampilkan Gambar
                    // Kalau null -> Tampilkan Icon Orang
                    backgroundImage: photoUrl != null
                        ? NetworkImage('${AppConstants.baseUrl}/$photoUrl')
                        : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Cari lapangan...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchQuery = "";
                          _searchCtrl.clear();
                        }),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          //  LIST LAPANGAN
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(fieldListControllerProvider),
              child: fieldListState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (fields) {
                  var displayList = fields.where((field) {
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch =
                        field.nama.toLowerCase().contains(query) ||
                        field.alamat.toLowerCase().contains(query);
                    if (_selectedFilter == "Futsal")
                      return matchesSearch && field.tipe == "Futsal";
                    if (_selectedFilter == "Mini Soccer")
                      return matchesSearch && field.tipe == "Mini Soccer";
                    if (_selectedFilter == "Sepak Bola")
                      return matchesSearch && field.tipe == "Sepak Bola";
                    return matchesSearch;
                  }).toList();

                  if (_selectedFilter == "Termurah")
                    displayList.sort(
                      (a, b) => a.hargaPerJam.compareTo(b.hargaPerJam),
                    );
                  else if (_selectedFilter == "Termahal")
                    displayList.sort(
                      (b, a) => a.hargaPerJam.compareTo(b.hargaPerJam),
                    );

                  if (displayList.isEmpty)
                    return const Center(child: Text("Tidak ditemukan."));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) => FieldCard(
                      field: displayList[index],
                      onTap: () =>
                          context.push('/field/${displayList[index].id}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
