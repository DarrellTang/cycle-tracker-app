import 'package:cycle_tracker_app/domain/entities/notification.dart';
import 'package:cycle_tracker_app/domain/repositories/notification_repository.dart';
import 'package:cycle_tracker_app/data/models/notification_model.dart';
import 'package:cycle_tracker_app/data/datasources/database_helper.dart';
import 'package:cycle_tracker_app/dependencies.dart';

/// Implementation of NotificationRepository using local SQLite database
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<CycleNotification> createNotification(CycleNotification notification) async {
    final model = CycleNotificationModel.fromEntity(notification);
    await DatabaseHelper.insertNotification(model);
    return model.toEntity();
  }

  @override
  Future<List<CycleNotification>> getPendingNotifications() async {
    final notifications = await DatabaseHelper.getPendingNotifications();
    return notifications.map((notification) => notification.toEntity()).toList();
  }

  @override
  Future<List<CycleNotification>> getNotificationsByProfileId(String profileId) async {
    final notifications = await DatabaseHelper.getNotificationsByProfileId(profileId);
    return notifications.map((notification) => notification.toEntity()).toList();
  }

  @override
  Future<List<CycleNotification>> getNotificationsByType(
    NotificationType type, {
    String? profileId,
  }) async {
    List<CycleNotificationModel> notifications;
    
    if (profileId != null) {
      notifications = await DatabaseHelper.getNotificationsByProfileId(profileId);
      notifications = notifications.where((n) => n.notificationType == type).toList();
    } else {
      // Get all notifications and filter by type
      final allNotifications = await DatabaseHelper.getPendingNotifications();
      notifications = allNotifications.where((n) => n.notificationType == type).toList();
    }

    return notifications.map((notification) => notification.toEntity()).toList();
  }

  @override
  Future<void> markNotificationAsSent(String notificationId) async {
    await DatabaseHelper.markNotificationAsSent(notificationId);
  }

  @override
  Future<CycleNotification> updateNotification(CycleNotification notification) async {
    final model = CycleNotificationModel.fromEntity(notification);
    await DatabaseHelper.insertNotification(model); // Uses REPLACE conflict algorithm
    return model.toEntity();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await DatabaseHelper.deleteNotification(id);
  }

  @override
  Future<List<CycleNotification>> schedulePhaseNotifications(
    String profileId,
    DateTime cycleStartDate,
    int cycleLength,
  ) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final notifications = <CycleNotification>[];

    // Calculate phase transition dates
    final follicularEnd = cycleStartDate.add(Duration(days: (cycleLength * 0.5).round()));
    final ovulationEnd = cycleStartDate.add(Duration(days: (cycleLength * 0.6).round()));
    final lutealEnd = cycleStartDate.add(Duration(days: cycleLength));

    // Phase transition notifications
    final phaseNotifications = [
      CycleNotification(
        id: uuid.v4(),
        profileId: profileId,
        notificationType: NotificationType.phaseTransition,
        title: 'Phase Transition',
        message: 'Follicular phase beginning - energy levels may start increasing',
        scheduledDate: cycleStartDate.add(const Duration(days: 5)), // End of menstrual
        createdAt: now,
      ),
      CycleNotification(
        id: uuid.v4(),
        profileId: profileId,
        notificationType: NotificationType.phaseTransition,
        title: 'Ovulation Phase',
        message: 'Ovulation phase starting - peak energy and confidence expected',
        scheduledDate: follicularEnd,
        createdAt: now,
      ),
      CycleNotification(
        id: uuid.v4(),
        profileId: profileId,
        notificationType: NotificationType.phaseTransition,
        title: 'Luteal Phase',
        message: 'Luteal phase beginning - be prepared for mood changes',
        scheduledDate: ovulationEnd,
        createdAt: now,
      ),
    ];

    // Save notifications
    for (final notification in phaseNotifications) {
      await createNotification(notification);
      notifications.add(notification);
    }

    return notifications;
  }

  @override
  Future<CycleNotification> schedulePeriodNotification(
    String profileId,
    DateTime expectedStartDate,
  ) async {
    const uuid = Uuid();
    
    final notification = CycleNotification(
      id: uuid.v4(),
      profileId: profileId,
      notificationType: NotificationType.periodStart,
      title: 'Period Expected',
      message: 'Period is expected to start soon. Consider preparing comfort items.',
      scheduledDate: expectedStartDate.subtract(const Duration(days: 1)),
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
    return notification;
  }

  @override
  Future<void> cancelNotificationsForProfile(String profileId) async {
    final notifications = await DatabaseHelper.getNotificationsByProfileId(profileId);
    
    for (final notification in notifications) {
      if (!notification.isSent) {
        await DatabaseHelper.deleteNotification(notification.id);
      }
    }
  }

  @override
  Future<List<CycleNotification>> getNotificationHistory(
    String profileId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final notifications = await DatabaseHelper.getNotificationsByProfileId(profileId);
    
    final history = notifications.where((notification) {
      return notification.scheduledDate.isAfter(startDate) &&
             notification.scheduledDate.isBefore(endDate);
    }).toList();

    return history.map((notification) => notification.toEntity()).toList();
  }
}