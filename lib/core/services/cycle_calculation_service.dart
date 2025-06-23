import 'dart:developer' as dev;
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/domain/entities/profile.dart';

/// Service for calculating cycle phases, predictions, and statistics
class CycleCalculationService {
  /// Calculate the cycle phase for a specific date based on cycle history
  CyclePhase calculatePhaseForDate(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    try {
      // If we have cycle history, use it for more accurate calculations
      if (cycleHistory.isNotEmpty) {
        return _calculatePhaseFromHistory(date, profile, cycleHistory);
      }

      // Fallback to default cycle calculation
      return _calculatePhaseFromDefaults(date, profile);
    } catch (e) {
      dev.log(
        'Error calculating phase for date: $e',
        name: 'CycleCalculationService',
      );
      return CyclePhase.follicular; // Safe fallback
    }
  }

  /// Check if a specific date is a period day based on cycle data
  bool isPeriodDay(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    try {
      // Check if date falls within any recorded period
      for (final cycle in cycleHistory) {
        if (_isDateInPeriod(date, cycle)) {
          return true;
        }
      }

      // If no recorded data, use predictions based on profile defaults
      return _isPredictedPeriodDay(date, profile, cycleHistory);
    } catch (e) {
      dev.log('Error checking period day: $e', name: 'CycleCalculationService');
      return false;
    }
  }

  /// Calculate cycle statistics for a profile
  CycleStatistics calculateCycleStatistics(
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    try {
      if (cycleHistory.isEmpty) {
        return CycleStatistics(
          averageCycleLength: profile.defaultCycleLength,
          averagePeriodLength: profile.defaultPeriodLength,
          totalCycles: 0,
          cycleVariability: 0,
          lastPeriodDate: null,
          nextPredictedPeriod: null,
        );
      }

      final completedCycles = _getCompletedCycles(cycleHistory);
      final cycleLengths = completedCycles.map((c) => c.cycleLength!).toList();
      final periodLengths = cycleHistory
          .where((c) => c.periodLength != null)
          .map((c) => c.periodLength!)
          .toList();

      final avgCycleLength = cycleLengths.isNotEmpty
          ? cycleLengths.reduce((a, b) => a + b) / cycleLengths.length
          : profile.defaultCycleLength.toDouble();

      final avgPeriodLength = periodLengths.isNotEmpty
          ? periodLengths.reduce((a, b) => a + b) / periodLengths.length
          : profile.defaultPeriodLength.toDouble();

      final variability = _calculateVariability(cycleLengths);
      final lastPeriod = _getLastPeriodDate(cycleHistory);
      final nextPredicted = _predictNextPeriod(
        lastPeriod,
        avgCycleLength.round(),
      );

      return CycleStatistics(
        averageCycleLength: avgCycleLength.round(),
        averagePeriodLength: avgPeriodLength.round(),
        totalCycles: completedCycles.length,
        cycleVariability: variability,
        lastPeriodDate: lastPeriod,
        nextPredictedPeriod: nextPredicted,
      );
    } catch (e) {
      dev.log(
        'Error calculating cycle statistics: $e',
        name: 'CycleCalculationService',
      );
      return CycleStatistics(
        averageCycleLength: profile.defaultCycleLength,
        averagePeriodLength: profile.defaultPeriodLength,
        totalCycles: 0,
        cycleVariability: 0,
        lastPeriodDate: null,
        nextPredictedPeriod: null,
      );
    }
  }

  /// Predict future cycle dates based on historical data
  List<DateTime> predictFuturePeriods(
    Profile profile,
    List<CycleRecord> cycleHistory,
    int monthsAhead,
  ) {
    try {
      final statistics = calculateCycleStatistics(profile, cycleHistory);
      final predictions = <DateTime>[];

      DateTime? lastPeriod = statistics.lastPeriodDate;
      lastPeriod ??= DateTime.now().subtract(
        Duration(days: profile.defaultCycleLength),
      );

      final avgCycleLength = statistics.averageCycleLength;
      final endDate = DateTime.now().add(Duration(days: monthsAhead * 30));

      DateTime nextPeriod = lastPeriod.add(Duration(days: avgCycleLength));

      while (nextPeriod.isBefore(endDate)) {
        predictions.add(nextPeriod);
        nextPeriod = nextPeriod.add(Duration(days: avgCycleLength));
      }

      return predictions;
    } catch (e) {
      dev.log(
        'Error predicting future periods: $e',
        name: 'CycleCalculationService',
      );
      return [];
    }
  }

  /// Calculate fertility window based on cycle data
  FertilityWindow calculateFertilityWindow(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    try {
      final statistics = calculateCycleStatistics(profile, cycleHistory);
      final avgCycleLength = statistics.averageCycleLength;

      // Find the current cycle's start date
      final cycleStartDate = _findCycleStartDate(date, profile, cycleHistory);

      // Ovulation typically occurs 14 days before next period
      final ovulationDay = cycleStartDate.add(
        Duration(days: avgCycleLength - 14),
      );

      // Fertile window is typically 6 days (5 days before + ovulation day)
      final fertileStart = ovulationDay.subtract(const Duration(days: 5));
      final fertileEnd = ovulationDay;

      return FertilityWindow(
        ovulationDate: ovulationDay,
        fertileStart: fertileStart,
        fertileEnd: fertileEnd,
        isCurrentlyFertile:
            date.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
            date.isBefore(fertileEnd.add(const Duration(days: 1))),
      );
    } catch (e) {
      dev.log(
        'Error calculating fertility window: $e',
        name: 'CycleCalculationService',
      );
      return FertilityWindow(
        ovulationDate: DateTime.now(),
        fertileStart: DateTime.now(),
        fertileEnd: DateTime.now(),
        isCurrentlyFertile: false,
      );
    }
  }

  // Private helper methods

  CyclePhase _calculatePhaseFromHistory(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    final cycleStartDate = _findCycleStartDate(date, profile, cycleHistory);
    final dayInCycle = date.difference(cycleStartDate).inDays + 1;

    final statistics = calculateCycleStatistics(profile, cycleHistory);
    final avgCycleLength = statistics.averageCycleLength;
    final avgPeriodLength = statistics.averagePeriodLength;

    return _calculatePhaseFromDayInCycle(
      dayInCycle,
      avgCycleLength,
      avgPeriodLength,
    );
  }

  CyclePhase _calculatePhaseFromDefaults(DateTime date, Profile profile) {
    // Use a reference date to calculate cycle day
    // For demo purposes, use a fixed reference date
    final referenceDate = DateTime(
      2024,
      1,
      1,
    ); // First day of a hypothetical cycle
    final daysSinceReference = date.difference(referenceDate).inDays;
    final dayInCycle = (daysSinceReference % profile.defaultCycleLength) + 1;

    return _calculatePhaseFromDayInCycle(
      dayInCycle,
      profile.defaultCycleLength,
      profile.defaultPeriodLength,
    );
  }

  CyclePhase _calculatePhaseFromDayInCycle(
    int dayInCycle,
    int cycleLength,
    int periodLength,
  ) {
    if (dayInCycle <= periodLength) {
      return CyclePhase.menstrual;
    } else if (dayInCycle <= (cycleLength / 2).floor()) {
      return CyclePhase.follicular;
    } else if (dayInCycle <= (cycleLength / 2).floor() + 3) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  bool _isDateInPeriod(DateTime date, CycleRecord cycle) {
    if (cycle.endDate == null) {
      // If no end date, check if it's the start date
      return _isSameDay(date, cycle.startDate);
    }

    return date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(cycle.endDate!.add(const Duration(days: 1)));
  }

  bool _isPredictedPeriodDay(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    final predictions = predictFuturePeriods(profile, cycleHistory, 3);

    for (final predictedDate in predictions) {
      // Check if date falls within predicted period duration
      for (int i = 0; i < profile.defaultPeriodLength; i++) {
        if (_isSameDay(date, predictedDate.add(Duration(days: i)))) {
          return true;
        }
      }
    }

    return false;
  }

  List<CycleRecord> _getCompletedCycles(List<CycleRecord> cycleHistory) {
    return cycleHistory
        .where((cycle) => cycle.cycleLength != null && cycle.cycleLength! > 0)
        .toList();
  }

  double _calculateVariability(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return 0;

    final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance =
        cycleLengths
            .map((length) => (length - mean) * (length - mean))
            .reduce((a, b) => a + b) /
        cycleLengths.length;

    return variance;
  }

  DateTime? _getLastPeriodDate(List<CycleRecord> cycleHistory) {
    if (cycleHistory.isEmpty) return null;

    // Sort by start date and get the most recent
    final sortedCycles = List<CycleRecord>.from(cycleHistory)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return sortedCycles.first.startDate;
  }

  DateTime? _predictNextPeriod(DateTime? lastPeriod, int avgCycleLength) {
    if (lastPeriod == null) return null;
    return lastPeriod.add(Duration(days: avgCycleLength));
  }

  DateTime _findCycleStartDate(
    DateTime date,
    Profile profile,
    List<CycleRecord> cycleHistory,
  ) {
    // Find the most recent cycle start before or on the given date
    final relevantCycles =
        cycleHistory
            .where(
              (cycle) =>
                  cycle.startDate.isBefore(date.add(const Duration(days: 1))),
            )
            .toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));

    if (relevantCycles.isNotEmpty) {
      return relevantCycles.first.startDate;
    }

    // Fallback: estimate based on default cycle length
    final daysSinceEpoch = date.difference(DateTime(2024, 1, 1)).inDays;
    final cycleNumber = daysSinceEpoch ~/ profile.defaultCycleLength;
    return DateTime(
      2024,
      1,
      1,
    ).add(Duration(days: cycleNumber * profile.defaultCycleLength));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Data class for cycle statistics
class CycleStatistics {
  final int averageCycleLength;
  final int averagePeriodLength;
  final int totalCycles;
  final double cycleVariability;
  final DateTime? lastPeriodDate;
  final DateTime? nextPredictedPeriod;

  const CycleStatistics({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.totalCycles,
    required this.cycleVariability,
    required this.lastPeriodDate,
    required this.nextPredictedPeriod,
  });
}

/// Data class for fertility window information
class FertilityWindow {
  final DateTime ovulationDate;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final bool isCurrentlyFertile;

  const FertilityWindow({
    required this.ovulationDate,
    required this.fertileStart,
    required this.fertileEnd,
    required this.isCurrentlyFertile,
  });
}
