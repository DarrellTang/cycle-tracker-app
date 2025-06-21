import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';
import 'package:cycle_tracker_app/domain/repositories/cycle_repository.dart';
import 'package:cycle_tracker_app/data/models/cycle_record_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';

/// Implementation of CycleRepository using local SQLite database
class CycleRepositoryImpl implements CycleRepository {
  @override
  Future<List<CycleRecord>> getCyclesByProfileId(String profileId) async {
    final cycles = await DatabaseHelper.getCyclesByProfileId(profileId);
    return cycles.map((cycle) => cycle.toEntity()).toList();
  }

  @override
  Future<CycleRecord?> getLatestCycleByProfileId(String profileId) async {
    final cycles = await DatabaseHelper.getCyclesByProfileId(profileId);
    return cycles.isNotEmpty ? cycles.first.toEntity() : null;
  }

  @override
  Future<CycleRecord?> getCycleById(String id) async {
    final cycles = await DatabaseHelper.getCyclesByProfileId('');
    final cycle = cycles.where((c) => c.id == id).firstOrNull;
    return cycle?.toEntity();
  }

  @override
  Future<CycleRecord> createCycle(CycleRecord cycle) async {
    final model = CycleRecordModel.fromEntity(cycle);
    await DatabaseHelper.insertCycleRecord(model);
    return model.toEntity();
  }

  @override
  Future<CycleRecord> updateCycle(CycleRecord cycle) async {
    final model = CycleRecordModel.fromEntity(
      cycle.copyWith(updatedAt: DateTime.now()),
    );
    await DatabaseHelper.updateCycleRecord(model);
    return model.toEntity();
  }

  @override
  Future<void> deleteCycle(String id) async {
    await DatabaseHelper.deleteCycleRecord(id);
  }

  @override
  Future<List<CycleRecord>> getCyclesInDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cycles = await DatabaseHelper.getCyclesByProfileId(profileId);
    final filtered = cycles.where((cycle) {
      return cycle.startDate.isAfter(startDate) && 
             cycle.startDate.isBefore(endDate);
    }).toList();
    return filtered.map((cycle) => cycle.toEntity()).toList();
  }
}
