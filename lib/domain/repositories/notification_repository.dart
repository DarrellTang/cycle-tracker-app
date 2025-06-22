import 'package:cycle_tracker_app/domain/entities/notification.dart';

/// Repository interface for notification data operations
abstract class NotificationRepository {
  /// Create a new notification
  Future<CycleNotification> createNotification(CycleNotification notification);

  /// Get pending notifications (not yet sent)
  Future<List<CycleNotification>> getPendingNotifications();

  /// Get notifications for a specific profile
  Future<List<CycleNotification>> getNotificationsByProfileId(String profileId);

  /// Get notifications by type
  Future<List<CycleNotification>> getNotificationsByType(
    NotificationType type, {
    String? profileId,
  });

  /// Mark notification as sent
  Future<void> markNotificationAsSent(String notificationId);

  /// Update notification
  Future<CycleNotification> updateNotification(CycleNotification notification);

  /// Delete notification
  Future<void> deleteNotification(String id);

  /// Schedule phase transition notifications
  Future<List<CycleNotification>> schedulePhaseNotifications(
    String profileId,
    DateTime cycleStartDate,
    int cycleLength,
  );

  /// Schedule period start notifications
  Future<CycleNotification> schedulePeriodNotification(
    String profileId,
    DateTime expectedStartDate,
  );

  /// Cancel all notifications for a profile
  Future<void> cancelNotificationsForProfile(String profileId);

  /// Get notification history
  Future<List<CycleNotification>> getNotificationHistory(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  );
}
