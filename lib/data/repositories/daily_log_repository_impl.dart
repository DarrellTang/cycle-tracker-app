import 'package:cycle_tracker_app/domain/entities/daily_log.dart';
import 'package:cycle_tracker_app/domain/repositories/daily_log_repository.dart';
import 'package:cycle_tracker_app/data/models/daily_log_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';

/// Implementation of DailyLogRepository using local SQLite database
class DailyLogRepositoryImpl implements DailyLogRepository {
  @override
  Future<DailyLog> createOrUpdateDailyLog(DailyLog dailyLog) async {
    final model = DailyLogModel.fromEntity(
      dailyLog.copyWith(updatedAt: DateTime.now()),
    );
    await DatabaseHelper.insertOrUpdateDailyLog(model);
    return model.toEntity();
  }

  @override
  Future<DailyLog?> getDailyLogForDate(String profileId, DateTime date) async {
    final dailyLog = await DatabaseHelper.getDailyLogForDate(profileId, date);
    return dailyLog?.toEntity();
  }

  @override
  Future<List<DailyLog>> getDailyLogsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    return dailyLogs.map((log) => log.toEntity()).toList();
  }

  @override
  Future<List<DailyLog>> getEnergyTrends(
    String profileId,
    int daysToAnalyze,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysToAnalyze));
    
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    
    // Filter logs that have energy level data
    final energyLogs = dailyLogs.where((log) => log.energyLevel != null).toList();
    return energyLogs.map((log) => log.toEntity()).toList();
  }

  @override
  Future<Map<MoodType, int>> getMoodFrequency(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    
    final moodCounts = <MoodType, int>{};
    for (final log in dailyLogs) {
      if (log.mood != null) {
        moodCounts[log.mood!] = (moodCounts[log.mood!] ?? 0) + 1;
      }
    }
    
    return moodCounts;
  }

  @override
  Future<List<DailyLog>> getDailyLogsForPhase(
    String profileId,
    String phaseType,
  ) async {
    // This would require joining with cycles and phases tables
    // For now, return recent logs as a placeholder
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    
    return dailyLogs.map((log) => log.toEntity()).toList();
  }

  @override
  Future<void> deleteDailyLog(String id) async {
    await DatabaseHelper.deleteDailyLog(id);
  }

  @override
  Future<Map<int, double>> getAverageEnergyByCycleDay(
    String profileId,
    int cyclesToAnalyze,
  ) async {
    // This would require complex queries joining cycles and daily logs
    // For now, return a simplified analysis
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: cyclesToAnalyze * 35));
    
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    
    final energyData = <int, List<int>>{};
    
    // Group by day of month as a simplified cycle day approximation
    for (final log in dailyLogs) {
      if (log.energyLevel != null) {
        final cycleDay = log.date.day;
        energyData[cycleDay] ??= [];
        energyData[cycleDay]!.add(log.energyLevel!);
      }
    }
    
    // Calculate averages
    final averages = <int, double>{};
    energyData.forEach((day, energyLevels) {
      final average = energyLevels.reduce((a, b) => a + b) / energyLevels.length;
      averages[day] = average;
    });
    
    return averages;
  }

  @override
  Future<List<DailyLog>> getSleepQualityTrends(
    String profileId,
    int daysToAnalyze,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysToAnalyze));
    
    final dailyLogs = await DatabaseHelper.getDailyLogsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    
    // Filter logs that have sleep quality data
    final sleepLogs = dailyLogs.where((log) => log.sleepQuality != null).toList();
    return sleepLogs.map((log) => log.toEntity()).toList();
  }
}