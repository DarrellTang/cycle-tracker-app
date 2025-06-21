import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/usecases/get_all_profiles.dart';
import 'package:cycle_tracker_app/core/providers/usecase_providers.dart';

/// State provider for managing profiles list
final profilesProvider =
    StateNotifierProvider<ProfilesNotifier, AsyncValue<List<Profile>>>((ref) {
      final getAllProfiles = ref.read(getAllProfilesProvider);
      return ProfilesNotifier(getAllProfiles);
    });

/// State notifier for managing profiles
class ProfilesNotifier extends StateNotifier<AsyncValue<List<Profile>>> {
  final GetAllProfiles _getAllProfiles;

  ProfilesNotifier(this._getAllProfiles) : super(const AsyncValue.loading()) {
    loadProfiles();
  }

  /// Load all profiles
  Future<void> loadProfiles() async {
    try {
      state = const AsyncValue.loading();
      final profiles = await _getAllProfiles();
      state = AsyncValue.data(profiles);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh profiles
  Future<void> refresh() async {
    await loadProfiles();
  }
}

/// Provider for selected profile
final selectedProfileProvider = StateProvider<Profile?>((ref) => null);

/// Provider for app initialization state
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Initialize database and other app dependencies here
  // For now, just return true after a short delay
  await Future.delayed(const Duration(milliseconds: 500));
  return true;
});
