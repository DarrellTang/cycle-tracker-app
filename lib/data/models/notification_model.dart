import 'package:cycle_tracker_app/domain/entities/notification.dart';

/// Data model for CycleNotification entity with serialization support
class CycleNotificationModel extends CycleNotification {
  const CycleNotificationModel({
    required super.id,
    required super.profileId,
    required super.notificationType,
    required super.title,
    required super.message,
    required super.scheduledDate,
    super.isSent = false,
    super.isEnabled = true,
    required super.createdAt,
  });

  /// Create CycleNotificationModel from CycleNotification entity
  factory CycleNotificationModel.fromEntity(CycleNotification notification) {
    return CycleNotificationModel(
      id: notification.id,
      profileId: notification.profileId,
      notificationType: notification.notificationType,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      isSent: notification.isSent,
      isEnabled: notification.isEnabled,
      createdAt: notification.createdAt,
    );
  }

  /// Create CycleNotificationModel from JSON map
  factory CycleNotificationModel.fromJson(Map<String, dynamic> json) {
    return CycleNotificationModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      notificationType: NotificationType.values.firstWhere(
        (type) => type.name == json['notification_type'] as String,
        orElse: () => NotificationType.custom,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      isSent: (json['is_sent'] as int) == 1,
      isEnabled: (json['is_enabled'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CycleNotificationModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'notification_type': notificationType.name,
      'title': title,
      'message': message,
      'scheduled_date': scheduledDate.toIso8601String(),
      'is_sent': isSent ? 1 : 0,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to CycleNotification entity
  CycleNotification toEntity() {
    return CycleNotification(
      id: id,
      profileId: profileId,
      notificationType: notificationType,
      title: title,
      message: message,
      scheduledDate: scheduledDate,
      isSent: isSent,
      isEnabled: isEnabled,
      createdAt: createdAt,
    );
  }

  /// Create a copy with new values
  @override
  CycleNotificationModel copyWith({
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
    return CycleNotificationModel(
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
