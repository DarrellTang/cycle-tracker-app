import 'package:cycle_tracker_app/domain/entities/phase.dart';
import 'package:cycle_tracker_app/domain/repositories/phase_repository.dart';
import 'package:cycle_tracker_app/data/models/phase_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';
import 'package:cycle_tracker_app/dependencies.dart';

/// Implementation of PhaseRepository using local SQLite database
class PhaseRepositoryImpl implements PhaseRepository {
  @override
  Future<Phase> createPhase(Phase phase) async {
    final model = PhaseModel.fromEntity(phase);
    await DatabaseHelper.insertPhase(model);
    return model.toEntity();
  }

  @override
  Future<List<Phase>> getPhasesByCycleId(String cycleId) async {
    final phases = await DatabaseHelper.getPhasesByCycleId(cycleId);
    return phases.map((phase) => phase.toEntity()).toList();
  }

  @override
  Future<Phase?> getCurrentPhase(String profileId) async {
    // Get current cycle first, then get its current phase
    final currentCycle = await DatabaseHelper.getCurrentCycle(profileId);
    if (currentCycle == null) return null;

    final phases = await DatabaseHelper.getPhasesByCycleId(currentCycle.id);
    if (phases.isEmpty) return null;

    // Calculate current cycle day
    final now = DateTime.now();
    final cycleStartDate = currentCycle.startDate;
    final cycleDay = now.difference(cycleStartDate).inDays + 1;

    // Find the phase that contains the current cycle day
    for (final phase in phases) {
      if (cycleDay >= phase.startDay && cycleDay <= phase.endDay) {
        return phase.toEntity();
      }
    }

    // Return the last phase if we're beyond the cycle
    return phases.last.toEntity();
  }

  @override
  Future<Phase> updatePhase(Phase phase) async {
    final model = PhaseModel.fromEntity(phase);
    await DatabaseHelper.insertPhase(model); // Uses REPLACE conflict algorithm
    return model.toEntity();
  }

  @override
  Future<void> deletePhasesByCycleId(String cycleId) async {
    await DatabaseHelper.deletePhasesByCycleId(cycleId);
  }

  @override
  Future<Map<PhaseType, int>> getAveragePhaseDurations(
    String profileId,
    int cyclesToAnalyze,
  ) async {
    final recentCycles = await DatabaseHelper.getRecentCycles(profileId, cyclesToAnalyze);
    final phaseDurations = <PhaseType, List<int>>{};

    for (final cycle in recentCycles) {
      final phases = await DatabaseHelper.getPhasesByCycleId(cycle.id);
      
      for (final phase in phases) {
        final duration = phase.endDay - phase.startDay + 1;
        phaseDurations[phase.phaseType] ??= [];
        phaseDurations[phase.phaseType]!.add(duration);
      }
    }

    // Calculate averages
    final averages = <PhaseType, int>{};
    phaseDurations.forEach((phaseType, durations) {
      final average = durations.reduce((a, b) => a + b) / durations.length;
      averages[phaseType] = average.round();
    });

    return averages;
  }

  @override
  Future<List<Phase>> createDefaultPhasesForCycle(
    String cycleId,
    int cycleLength,
  ) async {
    const uuid = Uuid();
    final now = DateTime.now();

    // Default phase durations (can be customized later)
    final defaultPhases = [
      Phase(
        id: uuid.v4(),
        cycleId: cycleId,
        phaseType: PhaseType.menstrual,
        startDay: 1,
        endDay: 5,
        duration: 5,
        createdAt: now,
      ),
      Phase(
        id: uuid.v4(),
        cycleId: cycleId,
        phaseType: PhaseType.follicular,
        startDay: 1,
        endDay: (cycleLength * 0.5).round(),
        duration: (cycleLength * 0.5).round(),
        createdAt: now,
      ),
      Phase(
        id: uuid.v4(),
        cycleId: cycleId,
        phaseType: PhaseType.ovulation,
        startDay: (cycleLength * 0.5).round() + 1,
        endDay: (cycleLength * 0.6).round(),
        duration: (cycleLength * 0.1).round(),
        createdAt: now,
      ),
      Phase(
        id: uuid.v4(),
        cycleId: cycleId,
        phaseType: PhaseType.luteal,
        startDay: (cycleLength * 0.6).round() + 1,
        endDay: cycleLength,
        duration: (cycleLength * 0.4).round(),
        createdAt: now,
      ),
    ];

    // Save phases to database
    for (final phase in defaultPhases) {
      await createPhase(phase);
    }

    return defaultPhases;
  }

  @override
  Future<List<Phase>> getPhaseHistory(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Get cycles in the date range
    final cycles = await DatabaseHelper.getCyclesByProfileId(profileId);
    final cyclesInRange = cycles.where((cycle) {
      return cycle.startDate.isAfter(startDate) && 
             cycle.startDate.isBefore(endDate);
    }).toList();

    final allPhases = <PhaseModel>[];
    for (final cycle in cyclesInRange) {
      final phases = await DatabaseHelper.getPhasesByCycleId(cycle.id);
      allPhases.addAll(phases);
    }

    // Sort by cycle start date and phase start day
    allPhases.sort((a, b) {
      // We would need to join with cycles table to get proper sorting
      // For now, sort by phase creation date
      return a.createdAt.compareTo(b.createdAt);
    });

    return allPhases.map((phase) => phase.toEntity()).toList();
  }
}