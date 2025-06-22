import 'package:cycle_tracker_app/domain/entities/daily_log.dart';

/// Repository interface for daily log data operations
abstract class DailyLogRepository {
  /// Create or update a daily log entry
  Future<DailyLog> createOrUpdateDailyLog(DailyLog dailyLog);

  /// Get daily log for a specific date
  Future<DailyLog?> getDailyLogForDate(String profileId, DateTime date);

  /// Get daily logs within a date range
  Future<List<DailyLog>> getDailyLogsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get energy level trends
  Future<List<DailyLog>> getEnergyTrends(String profileId, int daysToAnalyze);

  /// Get mood patterns
  Future<Map<MoodType, int>> getMoodFrequency(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get daily logs for a specific cycle phase
  Future<List<DailyLog>> getDailyLogsForPhase(
    String profileId,
    String phaseType,
  );

  /// Delete a daily log by ID
  Future<void> deleteDailyLog(String id);

  /// Get average energy levels by cycle day
  Future<Map<int, double>> getAverageEnergyByCycleDay(
    String profileId,
    int cyclesToAnalyze,
  );

  /// Get sleep quality trends
  Future<List<DailyLog>> getSleepQualityTrends(
    String profileId,
    int daysToAnalyze,
  );
}
