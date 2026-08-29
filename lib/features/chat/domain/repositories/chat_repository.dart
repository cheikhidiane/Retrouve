import 'package:template/shared/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String matchId);

  Future<ChatMessageEntity> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  });

  Future<ChatMessageEntity> addSystemMessage({
    required String matchId,
    required String text,
  });
}
