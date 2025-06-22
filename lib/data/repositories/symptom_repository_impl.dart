import 'package:cycle_tracker_app/domain/entities/symptom.dart';
import 'package:cycle_tracker_app/domain/repositories/symptom_repository.dart';
import 'package:cycle_tracker_app/data/models/symptom_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';

/// Implementation of SymptomRepository using local SQLite database
class SymptomRepositoryImpl implements SymptomRepository {
  @override
  Future<Symptom> createSymptom(Symptom symptom) async {
    final model = SymptomModel.fromEntity(symptom);
    await DatabaseHelper.insertSymptom(model);
    return model.toEntity();
  }

  @override
  Future<List<Symptom>> getSymptomsForDate(
    String profileId,
    DateTime date,
  ) async {
    final symptoms = await DatabaseHelper.getSymptomsForDate(profileId, date);
    return symptoms.map((symptom) => symptom.toEntity()).toList();
  }

  @override
  Future<List<Symptom>> getSymptomsByDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final symptoms = await DatabaseHelper.getSymptomsByDateRange(
      profileId,
      startDate,
      endDate,
    );
    return symptoms.map((symptom) => symptom.toEntity()).toList();
  }

  @override
  Future<List<Symptom>> getSymptomsByType(
    String profileId,
    SymptomType symptomType, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 90));
    final end = endDate ?? DateTime.now();

    final symptoms = await DatabaseHelper.getSymptomsByDateRange(
      profileId,
      start,
      end,
    );

    final filtered = symptoms
        .where((symptom) => symptom.symptomType == symptomType)
        .toList();

    return filtered.map((symptom) => symptom.toEntity()).toList();
  }

  @override
  Future<Symptom> updateSymptom(Symptom symptom) async {
    final model = SymptomModel.fromEntity(symptom);
    await DatabaseHelper.insertSymptom(
      model,
    ); // Uses REPLACE conflict algorithm
    return model.toEntity();
  }

  @override
  Future<void> deleteSymptom(String id) async {
    await DatabaseHelper.deleteSymptom(id);
  }

  @override
  Future<Map<SymptomType, List<Symptom>>> getSymptomPatterns(
    String profileId,
    int cyclesToAnalyze,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(
      Duration(days: cyclesToAnalyze * 35),
    ); // Approximate cycle length

    final symptoms = await DatabaseHelper.getSymptomsByDateRange(
      profileId,
      startDate,
      endDate,
    );

    final patterns = <SymptomType, List<Symptom>>{};
    for (final symptom in symptoms) {
      final entity = symptom.toEntity();
      if (!patterns.containsKey(entity.symptomType)) {
        patterns[entity.symptomType] = [];
      }
      patterns[entity.symptomType]!.add(entity);
    }

    return patterns;
  }

  @override
  Future<List<Symptom>> getSymptomsForPhase(
    String profileId,
    String phaseType,
  ) async {
    // This would require joining with cycles and phases tables
    // For now, return symptoms from the last 7 days as a placeholder
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));

    final symptoms = await DatabaseHelper.getSymptomsByDateRange(
      profileId,
      startDate,
      endDate,
    );

    return symptoms.map((symptom) => symptom.toEntity()).toList();
  }
}
