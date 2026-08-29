import 'package:equatable/equatable.dart';

enum NotificationType { newMatch, matchConfirmed, newMessage, itemRecovered }

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.relatedId,
    this.isRead = false,
  });

  final String id;

  /// The owner of the item this notification is about — only that user
  /// should ever see it. Older/legacy entries without this field
  /// (shouldn't happen post-cleanup, but kept defensive) default to an
  /// empty string, which matches no real user.
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? relatedId;
  final bool isRead;

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      relatedId: relatedId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'relatedId': relatedId,
        'isRead': isRead,
      };

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      type: NotificationType.values.byName(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, type, title, body, createdAt, relatedId, isRead];
}
