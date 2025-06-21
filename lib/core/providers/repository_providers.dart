import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';
import 'package:cycle_tracker_app/domain/repositories/cycle_repository.dart';
import 'package:cycle_tracker_app/data/repositories/profile_repository_impl.dart';
import 'package:cycle_tracker_app/data/repositories/cycle_repository_impl.dart';

/// Provider for ProfileRepository implementation
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Provider for CycleRepository implementation
final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  return CycleRepositoryImpl();
});
