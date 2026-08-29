import 'package:injectable/injectable.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/storages/json_list_store.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/notifications/domain/repositories/notification_repository.dart';
import 'package:template/shared/domain/entities/notification_entity.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._store, this._authRepository);

  final JsonListStore _store;
  final AuthRepository _authRepository;
  static const _key = 'notifications';
  static const _uuid = Uuid();

  Future<List<NotificationEntity>> _readAll() async {
    return _store.readList(_key).map(NotificationEntity.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _writeAll(List<NotificationEntity> items) {
    return _store.writeList(_key, items.map((e) => e.toJson()).toList());
  }

  /// Notifications are stored globally (single shared_preferences list for
  /// all local accounts), so every read must be scoped to the currently
  /// logged-in user — otherwise every user would see everyone else's
  /// notifications.
  Future<List<NotificationEntity>> _readAllForCurrentUser() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) return [];
    final all = await _readAll();
    return all.where((n) => n.userId == user.id).toList();
  }

  @override
  Future<List<NotificationEntity>> getAll() => _readAllForCurrentUser();

  @override
  Future<int> unreadCount() async {
    final mine = await _readAllForCurrentUser();
    return mine.where((n) => !n.isRead).length;
  }

  @override
  Future<NotificationEntity> add({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
  }) async {
    final all = await _readAll();
    final notif = NotificationEntity(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      relatedId: relatedId,
    );
    all.add(notif);
    await _writeAll(all);
    DataRefreshBus.instance.bump();
    return notif;
  }

  @override
  Future<void> markAllRead() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) return;
    final all = await _readAll();
    final updated = all
        .map((n) => n.userId == user.id ? n.copyWith(isRead: true) : n)
        .toList();
    await _writeAll(updated);
    DataRefreshBus.instance.bump();
  }
}
