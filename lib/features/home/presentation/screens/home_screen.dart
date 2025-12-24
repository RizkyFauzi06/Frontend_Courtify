import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../field/presentation/controllers/field_list_controller.dart';
import '../../../field/presentation/widgets/field_card.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
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

  // HELPER BERSIH-BERSIH URL Untuk Foto Profil
  String? _constructDynamicUrl(String? rawPath, String currentIp) {
    if (rawPath == null || rawPath.isEmpty) return null;

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

  @override
  Widget build(BuildContext context) {
    final fieldListState = ref.watch(fieldListControllerProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    // AMBIL IP DINAMIS DARI LOGIN
    final currentIp = ref.watch(baseUrlProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
              context.push('/owner-request');
            },
          ),
          // TOMBOL HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
          // TOMBOL MEMBERSHIP
          IconButton(
            icon: const Icon(Icons.card_membership),
            onPressed: () => context.push('/membership'),
          ),

          // FOTO PROFIL
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Consumer(
                builder: (context, ref, child) {
                  final rawPhotoPath = ref.watch(userPhotoProvider);

                  // BERSIHKAN URL FOTO PROFIL
                  final fullProfileUrl = _constructDynamicUrl(
                    rawPhotoPath,
                    currentIp,
                  );

                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: fullProfileUrl != null
                        ? NetworkImage(fullProfileUrl)
                        : null,
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: fullProfileUrl == null
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

          // LIST LAPANGAN
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

                      //kirim OBJECT 'extra'
                      onTap: () => context.push(
                        '/field-detail', //
                        extra: displayList[index], // Bawa data lengkap
                      ),
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
