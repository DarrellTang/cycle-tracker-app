import 'package:flutter_test/flutter_test.dart';
import 'package:cycle_tracker_app/dependencies.dart';

void main() {
  group('Dependencies Test', () {
    test('should import Riverpod state management', () {
      // Test that Riverpod classes are available
      expect(ProviderContainer, isNotNull);
      expect(StateProvider, isNotNull);
    });

    test('should import HTTP packages', () {
      // Test that Dio is available (our primary HTTP client)
      expect(Dio, isNotNull);
    });

    test('should import local storage packages', () {
      // Test that SQLite and SharedPreferences are available
      expect(openDatabase, isNotNull);
      expect(SharedPreferences, isNotNull);
    });

    test('should import date and calendar utilities', () {
      // Test that calendar and date utilities are available
      expect(TableCalendar, isNotNull);
      expect(DateFormat, isNotNull);
    });

    test('should import chart library', () {
      // Test that chart library is available
      expect(LineChart, isNotNull);
    });

    test('should import path utilities', () {
      // Test that path utilities are available
      expect(join, isNotNull);
      expect(dirname, isNotNull);
    });
  });
}