import 'package:cycle_tracker_app/domain/entities/profile.dart';
import 'package:cycle_tracker_app/domain/repositories/profile_repository.dart';

/// Use case for retrieving all profiles
class GetAllProfiles {
  final ProfileRepository _repository;

  const GetAllProfiles(this._repository);

  /// Execute the use case to get all profiles
  Future<List<Profile>> call() async {
    return await _repository.getAllProfiles();
  }
}
