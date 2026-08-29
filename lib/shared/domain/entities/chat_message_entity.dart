import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isSystem = false,
  });

  final String id;
  final String matchId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isSystem;

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'isSystem': isSystem,
      };

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [id, matchId, senderId, text, createdAt, isSystem];
}
