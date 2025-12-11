import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/owner_repository.dart';

// Model Gabungan untuk UI
class OwnerDashboardData {
  final DashboardStats stats;
  final List<JamRamai> jamRamai;
  final List<LapanganTerlaris> terlaris;

  OwnerDashboardData({
    required this.stats,
    required this.jamRamai,
    required this.terlaris,
  });
}

final ownerDashboardControllerProvider =
    FutureProvider.autoDispose<OwnerDashboardData>((ref) async {
      final repo = ref.watch(ownerRepositoryProvider);

      // Panggil Parallel (Biar Cepat)
      final stats = repo.getStats();
      final jam = repo.getJamRamai();
      final laris = repo.getLapanganTerlaris();

      return OwnerDashboardData(
        stats: await stats,
        jamRamai: await jam,
        terlaris: await laris,
      );
    });
