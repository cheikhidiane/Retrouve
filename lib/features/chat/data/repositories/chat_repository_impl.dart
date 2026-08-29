import 'package:injectable/injectable.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/storages/json_list_store.dart';
import 'package:template/features/chat/domain/repositories/chat_repository.dart';
import 'package:template/shared/domain/entities/chat_message_entity.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._store);

  final JsonListStore _store;
  static const _uuid = Uuid();

  String _key(String matchId) => 'chat_messages_$matchId';

  Future<List<ChatMessageEntity>> _readAll(String matchId) async {
    return _store
        .readList(_key(matchId))
        .map(ChatMessageEntity.fromJson)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _writeAll(String matchId, List<ChatMessageEntity> items) {
    return _store.writeList(
      _key(matchId),
      items.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(String matchId) =>
      _readAll(matchId);

  @override
  Future<ChatMessageEntity> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    final all = await _readAll(matchId);
    final message = ChatMessageEntity(
      id: _uuid.v4(),
      matchId: matchId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );
    all.add(message);
    await _writeAll(matchId, all);
    DataRefreshBus.instance.bump();
    return message;
  }

  @override
  Future<ChatMessageEntity> addSystemMessage({
    required String matchId,
    required String text,
  }) async {
    final all = await _readAll(matchId);
    final message = ChatMessageEntity(
      id: _uuid.v4(),
      matchId: matchId,
      senderId: 'system',
      text: text,
      createdAt: DateTime.now(),
      isSystem: true,
    );
    all.add(message);
    await _writeAll(matchId, all);
    DataRefreshBus.instance.bump();
    return message;
  }
}
