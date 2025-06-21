import 'package:cycle_tracker_app/domain/entities/cycle_record.dart';

/// Repository interface for cycle data operations
abstract class CycleRepository {
  /// Get all cycle records for a profile
  Future<List<CycleRecord>> getCyclesByProfileId(String profileId);

  /// Get the most recent cycle for a profile
  Future<CycleRecord?> getLatestCycleByProfileId(String profileId);

  /// Get a cycle record by ID
  Future<CycleRecord?> getCycleById(String id);

  /// Create a new cycle record
  Future<CycleRecord> createCycle(CycleRecord cycle);

  /// Update an existing cycle record
  Future<CycleRecord> updateCycle(CycleRecord cycle);

  /// Delete a cycle record by ID
  Future<void> deleteCycle(String id);

  /// Get cycle records within a date range
  Future<List<CycleRecord>> getCyclesInDateRange(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );
}