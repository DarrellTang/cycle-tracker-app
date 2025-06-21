import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/usecases/get_all_profiles.dart';
import 'package:cycle_tracker_app/domain/usecases/get_current_cycle_phase.dart';
import 'package:cycle_tracker_app/core/providers/repository_providers.dart';

/// Provider for GetAllProfiles use case
final getAllProfilesProvider = Provider<GetAllProfiles>((ref) {
  final profileRepository = ref.read(profileRepositoryProvider);
  return GetAllProfiles(profileRepository);
});

/// Provider for GetCurrentCyclePhase use case
final getCurrentCyclePhaseProvider = Provider<GetCurrentCyclePhase>((ref) {
  final cycleRepository = ref.read(cycleRepositoryProvider);
  return GetCurrentCyclePhase(cycleRepository);
});