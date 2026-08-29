import 'package:template/shared/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Returns only the notifications belonging to the currently logged-in
  /// user.
  Future<List<NotificationEntity>> getAll();

  Future<int> unreadCount();

  Future<NotificationEntity> add({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
  });

  /// Marks only the current user's notifications as read.
  Future<void> markAllRead();
}
