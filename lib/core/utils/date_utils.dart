import 'package:cycle_tracker_app/dependencies.dart';
import 'package:cycle_tracker_app/core/constants/app_constants.dart';

/// Utility class for date-related operations
class DateUtils {
  /// Format date for display
  static String formatDisplayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  /// Format date for database storage
  static String formatDatabaseDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }

  /// Parse date from database format
  static DateTime parseDatabaseDate(String dateString) {
    return DateFormat(AppConstants.dateFormat).parse(dateString);
  }

  /// Get the start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get the number of days between two dates
  static int daysBetween(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Subtract days from a date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Get the first day of the month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the last day of the month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get days in current month
  static int daysInMonth(DateTime date) {
    return lastDayOfMonth(date).day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(startOfDay(now));
  }

  /// Check if a date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(endOfDay(now));
  }

  /// Get relative time description (e.g., "2 days ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = daysBetween(startOfDay(now), startOfDay(date));

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}