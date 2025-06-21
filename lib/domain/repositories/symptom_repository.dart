import 'package:cycle_tracker_app/domain/entities/symptom.dart';

/// Repository interface for symptom data operations
abstract class SymptomRepository {
  /// Create a new symptom entry
  Future<Symptom> createSymptom(Symptom symptom);

  /// Get symptoms for a specific date
  Future<List<Symptom>> getSymptomsForDate(String profileId, DateTime date);

  /// Get symptoms within a date range
  Future<List<Symptom>> getSymptomsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get symptoms by type for analysis
  Future<List<Symptom>> getSymptomsByType(
    String profileId,
    SymptomType symptomType,
    {DateTime? startDate, DateTime? endDate}
  );

  /// Update an existing symptom
  Future<Symptom> updateSymptom(Symptom symptom);

  /// Delete a symptom by ID
  Future<void> deleteSymptom(String id);

  /// Get symptom patterns for predictions
  Future<Map<SymptomType, List<Symptom>>> getSymptomPatterns(
    String profileId,
    int cyclesToAnalyze,
  );

  /// Get common symptoms for a specific cycle phase
  Future<List<Symptom>> getSymptomsForPhase(
    String profileId,
    String phaseType,
  );
}