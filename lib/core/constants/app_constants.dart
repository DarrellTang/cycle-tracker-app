/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Cycle Tracker';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'cycle_tracker.db';
  static const int databaseVersion = 1;
  
  // Cycle Calculations
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int minPeriodLength = 3;
  static const int maxPeriodLength = 7;
  
  // Phase Durations (in days)
  static const int menstrualPhaseDuration = 5;
  static const int follicularPhaseDuration = 8;
  static const int ovulationPhaseDuration = 3;
  static const int lutealPhaseDuration = 12;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMM yyyy';
  
  // Security
  static const String biometricStorageKey = 'cycle_tracker_biometric';
  
  // Notifications
  static const String notificationChannelId = 'cycle_tracker_notifications';
  static const String notificationChannelName = 'Cycle Tracker';
  static const String notificationChannelDescription = 'Notifications for cycle tracking';
}