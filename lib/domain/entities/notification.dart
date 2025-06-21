import 'package:equatable/equatable.dart';

/// Represents a scheduled notification for cycle tracking
class CycleNotification extends Equatable {
  const CycleNotification({
    required this.id,
    required this.profileId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.scheduledDate,
    this.isSent = false,
    this.isEnabled = true,
    required this.createdAt,
  });

  final String id;
  final String profileId;
  final NotificationType notificationType;
  final String title;
  final String message;
  final DateTime scheduledDate;
  final bool isSent;
  final bool isEnabled;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        profileId,
        notificationType,
        title,
        message,
        scheduledDate,
        isSent,
        isEnabled,
        createdAt,
      ];

  CycleNotification copyWith({
    String? id,
    String? profileId,
    NotificationType? notificationType,
    String? title,
    String? message,
    DateTime? scheduledDate,
    bool? isSent,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return CycleNotification(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isSent: isSent ?? this.isSent,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Enumeration of notification types
enum NotificationType {
  phaseTransition,
  periodStart,
  lowEnergyDay,
  moodSensitivity,
  symptomReminder,
  supportSuggestion,
  logReminder,
  custom,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.phaseTransition:
        return 'Phase Transition';
      case NotificationType.periodStart:
        return 'Period Start';
      case NotificationType.lowEnergyDay:
        return 'Low Energy Day';
      case NotificationType.moodSensitivity:
        return 'Mood Sensitivity';
      case NotificationType.symptomReminder:
        return 'Symptom Reminder';
      case NotificationType.supportSuggestion:
        return 'Support Suggestion';
      case NotificationType.logReminder:
        return 'Log Reminder';
      case NotificationType.custom:
        return 'Custom';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.phaseTransition:
        return 'Notifications when cycle phases change';
      case NotificationType.periodStart:
        return 'Notifications for predicted period start';
      case NotificationType.lowEnergyDay:
        return 'Alerts for predicted low energy days';
      case NotificationType.moodSensitivity:
        return 'Reminders about mood sensitivity periods';
      case NotificationType.symptomReminder:
        return 'Reminders to log symptoms';
      case NotificationType.supportSuggestion:
        return 'Daily support tips and suggestions';
      case NotificationType.logReminder:
        return 'Reminders to log daily observations';
      case NotificationType.custom:
        return 'Custom user-defined notifications';
    }
  }
}