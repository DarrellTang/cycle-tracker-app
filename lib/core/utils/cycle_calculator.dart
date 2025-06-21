import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/core/constants/app_constants.dart';

/// Utility class for cycle-related calculations
class CycleCalculator {
  /// Calculate the current cycle phase based on start date
  static CyclePhase calculateCurrentPhase(DateTime cycleStartDate) {
    final daysSinceStart = DateTime.now().difference(cycleStartDate).inDays;

    if (daysSinceStart < 0) {
      // Future start date, shouldn't happen but handle gracefully
      return CyclePhase.menstrual;
    }

    if (daysSinceStart < AppConstants.menstrualPhaseDuration) {
      return CyclePhase.menstrual;
    } else if (daysSinceStart <
        AppConstants.menstrualPhaseDuration +
            AppConstants.follicularPhaseDuration) {
      return CyclePhase.follicular;
    } else if (daysSinceStart <
        AppConstants.menstrualPhaseDuration +
            AppConstants.follicularPhaseDuration +
            AppConstants.ovulationPhaseDuration) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Predict the next period start date based on cycle history
  static DateTime? predictNextPeriod(List<CycleRecord> cycleHistory) {
    if (cycleHistory.isEmpty) {
      return null;
    }

    // Sort cycles by start date (most recent first)
    final sortedCycles = List<CycleRecord>.from(cycleHistory)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final latestCycle = sortedCycles.first;

    // Calculate average cycle length from recent cycles
    int averageCycleLength = AppConstants.defaultCycleLength;

    if (sortedCycles.length > 1) {
      final recentCycles = sortedCycles.take(6).toList(); // Use last 6 cycles
      int totalLength = 0;
      int count = 0;

      for (int i = 0; i < recentCycles.length - 1; i++) {
        final current = recentCycles[i];
        final previous = recentCycles[i + 1];
        final cycleLength = current.startDate
            .difference(previous.startDate)
            .inDays;

        // Only use reasonable cycle lengths
        if (cycleLength >= AppConstants.minCycleLength &&
            cycleLength <= AppConstants.maxCycleLength) {
          totalLength += cycleLength;
          count++;
        }
      }

      if (count > 0) {
        averageCycleLength = (totalLength / count).round();
      }
    }

    // Predict next period
    return latestCycle.startDate.add(Duration(days: averageCycleLength));
  }

  /// Calculate cycle day (day 1 is first day of period)
  static int calculateCycleDay(DateTime cycleStartDate) {
    final daysSinceStart = DateTime.now().difference(cycleStartDate).inDays;
    return daysSinceStart + 1; // Day 1 is the first day of period
  }

  /// Get estimated ovulation date for a cycle
  static DateTime getEstimatedOvulationDate(
    DateTime cycleStartDate, {
    int cycleLength = AppConstants.defaultCycleLength,
  }) {
    // Ovulation typically occurs 14 days before the next period
    const ovulationDaysBeforeNextPeriod = 14;
    final ovulationDay = cycleLength - ovulationDaysBeforeNextPeriod;
    return cycleStartDate.add(
      Duration(days: ovulationDay - 1),
    ); // -1 because day 1 is start
  }

  /// Get fertile window (5-day window around ovulation)
  static List<DateTime> getFertileWindow(
    DateTime cycleStartDate, {
    int cycleLength = AppConstants.defaultCycleLength,
  }) {
    final ovulationDate = getEstimatedOvulationDate(
      cycleStartDate,
      cycleLength: cycleLength,
    );
    final fertileStart = ovulationDate.subtract(const Duration(days: 2));
    final fertileEnd = ovulationDate.add(const Duration(days: 2));

    final fertileWindow = <DateTime>[];
    for (
      var date = fertileStart;
      date.isBefore(fertileEnd.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      fertileWindow.add(date);
    }

    return fertileWindow;
  }

  /// Check if a date falls within the fertile window
  static bool isInFertileWindow(
    DateTime date,
    DateTime cycleStartDate, {
    int cycleLength = AppConstants.defaultCycleLength,
  }) {
    final fertileWindow = getFertileWindow(
      cycleStartDate,
      cycleLength: cycleLength,
    );
    return fertileWindow.any(
      (fertileDate) =>
          date.year == fertileDate.year &&
          date.month == fertileDate.month &&
          date.day == fertileDate.day,
    );
  }

  /// Validate cycle length
  static bool isValidCycleLength(int cycleLength) {
    return cycleLength >= AppConstants.minCycleLength &&
        cycleLength <= AppConstants.maxCycleLength;
  }

  /// Validate period length
  static bool isValidPeriodLength(int periodLength) {
    return periodLength >= AppConstants.minPeriodLength &&
        periodLength <= AppConstants.maxPeriodLength;
  }

  /// Get phase color for UI display
  static Color getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const Color(0xFFE57373); // Red
      case CyclePhase.follicular:
        return const Color(0xFF81C784); // Green
      case CyclePhase.ovulation:
        return const Color(0xFFFFB74D); // Orange
      case CyclePhase.luteal:
        return const Color(0xFF9575CD); // Purple
    }
  }

  /// Get next phase after the current one
  static CyclePhase getNextPhase(CyclePhase currentPhase) {
    switch (currentPhase) {
      case CyclePhase.menstrual:
        return CyclePhase.follicular;
      case CyclePhase.follicular:
        return CyclePhase.ovulation;
      case CyclePhase.ovulation:
        return CyclePhase.luteal;
      case CyclePhase.luteal:
        return CyclePhase.menstrual;
    }
  }
}
