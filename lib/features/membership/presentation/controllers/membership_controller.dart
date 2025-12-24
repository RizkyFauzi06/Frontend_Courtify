import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/membership_model.dart';
import '../../data/repositories/membership_repository.dart';

// Provider untuk List Paket
final membershipListProvider =
    FutureProvider.autoDispose<List<MembershipModel>>((ref) {
      return ref.watch(membershipRepositoryProvider).getMemberships();
    });
