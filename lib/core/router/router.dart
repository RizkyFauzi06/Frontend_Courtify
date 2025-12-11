import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/storage_provider.dart';

// --- IMPORT SCREEN ---
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/field/presentation/screens/field_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/upload_payment_screen.dart';
import '../../features/booking/presentation/screens/history_screen.dart';
import '../../features/membership/presentation/screens/membership_screen.dart';
import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner/presentation/screens/owner_main_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:frontend_futsal/features/booking/presentation/screens/upload_payment_screen.dart';
import '../../features/home/presentation/screens/owner_request_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) { // nge provide Gorouter ke variabel goRouterProvider
  final storage = ref.watch(storageProvider); // baca storage agar meyimpan dan mengambil

  Future<String?> redirect(BuildContext context, GoRouterState state) async { 
                  // fungsi redirect yang menentukan halaman apa butuh apa
    final isSplash = state.matchedLocation == '/';
    if (isSplash) { // menampilkan splash screen
      return null;
    }
    print('ROUTER CEK: ${state.matchedLocation}');

    final token = await storage.read(key: 'token'); //daptin token dari backend / DB
    final loggedIn = token != null; 
    final isLogin = state.matchedLocation == '/login';
    final isRegister = state.matchedLocation == '/register';
    // SUDAH LOGIN (Cegah balik ke Login/Register)
    if (loggedIn && (isLogin || isRegister)) {
      return '/home';
    }

    // BELUM LOGIN (Cegah masuk Home/Detail)
    if (!loggedIn && !isLogin && !isRegister) {
      return '/login';
    }

    return null;
  }

  return GoRouter(
    initialLocation: '/',
    redirect: redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/field/:fieldId', // Pake titik dua (:) buat parameter
        name: 'field-detail',
        builder: (context, state) {
          // Tangkap ID dari URL
          final id = state.pathParameters['fieldId']!;
          return FieldDetailScreen(fieldId: id);
        },
      ),
      GoRoute(
        path: '/booking/:fieldId',
        name: 'booking',
        builder: (context, state) {
          final id = state.pathParameters['fieldId']!;
          final extra = state.extra as Map<String, dynamic>;
          return BookingScreen(
            fieldId: id,
            fieldName: extra['name'], // Ambil nama
            pricePerHour: extra['price'], // Ambil harga
          );
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/membership',
        name: 'membership',
        builder: (context, state) => const MembershipScreen(),
      ),

      GoRoute(
        path: '/owner-dashboard',
        name: 'owner-dashboard',
        builder: (context, state) =>
            const OwnerMainScreen(), // <-- Pake screen yang ada navbar
      ),
      GoRoute(
        path: '/owner-request',
        name: 'owner-request',
        builder: (context, state) => const OwnerRequestScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      )
      GoRoute(
        path: '/upload-payment/:bookingId',
        name: 'upload-payment',
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final rek = extra?['rekening'] ?? 'BCA -';

          return UploadPaymentScreen(bookingId: id, rekeningTujuan: rek);
        },
      ),
      // ------------------------------------------
    ],
  );
});
