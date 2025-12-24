import 'package:flutter/material.dart'; // mengambil material ui google
import 'package:flutter_riverpod/flutter_riverpod.dart'; // memanggil state management untuk komunikasi antar data
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/storage_provider.dart';
import '../../data/repositories/admin_repository.dart';
import 'package:frontend_futsal/features/admin/data/models/owner_request_model.dart';
import 'admin_request_detail_screen.dart'; // Detail Pengajuan Owner
import 'admin_member_verification_screen.dart'; // Screen Verifikasi Member

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState(); //
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Calon Owner", icon: Icon(Icons.person_add)),
            Tab(text: "Membership", icon: Icon(Icons.card_membership)),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(storageProvider).deleteAll();
                  if (context.mounted) context.go('/login');
                },
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OwnerRequestList(), AdminMemberVerificationScreen()],
      ),
    );
  }
}

// WIDGET LIST PENGAJUAN OWNER
class _OwnerRequestList extends ConsumerStatefulWidget {
  const _OwnerRequestList();

  @override
  ConsumerState<_OwnerRequestList> createState() => _OwnerRequestListState();
}

class _OwnerRequestListState extends ConsumerState<_OwnerRequestList> {
  Future<List<OwnerRequestModel>>? _futureRequests;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futureRequests = ref.read(adminRepositoryProvider).getRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data ?? [];

        if (list.isEmpty) {
          return const Center(child: Text("Tidak ada pengajuan Owner baru."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminOwnerVerificationScreen(request: item),
                  ),
                );
                _refreshData(); // Refresh pas balik
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    item.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Bisnis: ${item.bisnis}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
