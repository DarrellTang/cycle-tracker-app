import 'package:cycle_tracker_app/domain/entities/phase.dart';

/// Repository interface for phase data operations
abstract class PhaseRepository {
  /// Create a phase record
  Future<Phase> createPhase(Phase phase);

  /// Get all phases for a cycle
  Future<List<Phase>> getPhasesByCycleId(String cycleId);

  /// Get current phase for a profile
  Future<Phase?> getCurrentPhase(String profileId);

  /// Update phase predictions
  Future<Phase> updatePhase(Phase phase);

  /// Delete phases for a cycle
  Future<void> deletePhasesByCycleId(String cycleId);

  /// Get phase duration patterns
  Future<Map<PhaseType, int>> getAveragePhaseDurations(
    String profileId,
    int cyclesToAnalyze,
  );

  /// Create default phases for a new cycle
  Future<List<Phase>> createDefaultPhasesForCycle(
    String cycleId,
    int cycleLength,
  );

  /// Get phase transition history
  Future<List<Phase>> getPhaseHistory(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );
}