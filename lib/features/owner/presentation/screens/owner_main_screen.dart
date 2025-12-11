import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'owner_dashboard_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import 'manage_fields_screen.dart';
import 'verification_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OwnerDashboardScreen(),
    const VerificationScreen(),
    const ManageFieldsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          // TAB BARU:
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            label: 'Verifikasi',
          ),
          NavigationDestination(icon: Icon(Icons.edit_road), label: 'Kelola'),
        ],
      ),
    );
  }
}
