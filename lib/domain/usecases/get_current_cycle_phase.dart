import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/domain/repositories/cycle_repository.dart';

/// Use case for getting the current cycle phase for a profile
class GetCurrentCyclePhase {
  final CycleRepository _repository;

  const GetCurrentCyclePhase(this._repository);

  /// Execute the use case to get current cycle phase
  /// Returns null if no cycle data exists
  Future<CyclePhase?> call(String profileId) async {
    final latestCycle = await _repository.getLatestCycleByProfileId(profileId);
    
    if (latestCycle == null) {
      return null;
    }

    // Calculate current phase based on cycle start date and current date
    final daysSinceStart = DateTime.now().difference(latestCycle.startDate).inDays;
    
    // Simple phase calculation (would be more sophisticated in real implementation)
    if (daysSinceStart <= 5) {
      return CyclePhase.menstrual;
    } else if (daysSinceStart <= 13) {
      return CyclePhase.follicular;
    } else if (daysSinceStart <= 16) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }
}