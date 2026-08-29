import 'package:injectable/injectable.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/storages/json_list_store.dart';
import 'package:template/features/chat/domain/repositories/chat_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/features/notifications/domain/repositories/notification_repository.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/entities/notification_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:uuid/uuid.dart';

/// Minimal (but real) matching algorithm: scores every unmatched
/// lost/found pair on category, keyword overlap (title + description) and
/// location similarity. This intentionally stays simple — it is not meant
/// to be a production-grade recommendation engine, only enough to produce
/// a believable "potential match" during the demo.
@LazySingleton(as: MatchRepository)
class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(
    this._store,
    this._itemRepository,
    this._notifications,
    this._chatRepository,
  );

  final JsonListStore _store;
  final ItemRepository _itemRepository;
  final NotificationRepository _notifications;
  final ChatRepository _chatRepository;

  static const _key = 'matches';
  static const _uuid = Uuid();
  static const _scoreThreshold = 40;

  static const _stopWords = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'de',
    'du',
    'et',
    'en',
    'a',
    'au',
    'aux',
    'avec',
    'pour',
    'dans',
    'sur',
    'mon',
    'ma',
    'mes',
  };

  Future<List<MatchEntity>> _readAll() async {
    return _store.readList(_key).map(MatchEntity.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _writeAll(List<MatchEntity> items) {
    return _store.writeList(_key, items.map((e) => e.toJson()).toList());
  }

  Set<String> _tokens(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-zàâäéèêëîïôöùûüç0-9]+'))
        .where((w) => w.length >= 3 && !_stopWords.contains(w))
        .toSet();
  }

  int _score(ItemEntity lost, ItemEntity found) {
    var score = 0;

    if (lost.category.toLowerCase() == found.category.toLowerCase()) {
      score += 40;
    }

    final lostTokens = _tokens('${lost.title} ${lost.description}');
    final foundTokens = _tokens(found.description);
    if (lostTokens.isNotEmpty && foundTokens.isNotEmpty) {
      final common = lostTokens.intersection(foundTokens).length;
      final union = lostTokens.union(foundTokens).length;
      if (union > 0) {
        score += ((common / union) * 40).round();
      }
    }

    final lostLocationTokens = _tokens(lost.location);
    final foundLocationTokens = _tokens(found.location);
    if (lostLocationTokens.intersection(foundLocationTokens).isNotEmpty) {
      score += 20;
    }

    return score.clamp(0, 100);
  }

  @override
  Future<List<MatchEntity>> getAll() => _readAll();

  @override
  Future<MatchEntity?> getById(String id) async {
    final all = await _readAll();
    for (final match in all) {
      if (match.id == id) return match;
    }
    return null;
  }

  @override
  Future<List<MatchEntity>> generateMatches() async {
    final lostItems = await _itemRepository.getByKind(ItemKind.lost);
    final foundItems = await _itemRepository.getByKind(ItemKind.found);
    final existing = await _readAll();

    final created = <MatchEntity>[];

    for (final lost in lostItems.where((i) => !i.isMatched)) {
      for (final found in foundItems.where((i) => !i.isMatched)) {
        final alreadyExists = existing.any(
          (m) => m.lostItemId == lost.id && m.foundItemId == found.id,
        );
        if (alreadyExists) continue;

        final score = _score(lost, found);
        if (score < _scoreThreshold) continue;

        final match = MatchEntity(
          id: _uuid.v4(),
          lostItemId: lost.id,
          foundItemId: found.id,
          score: score,
          status: MatchStatus.potential,
          createdAt: DateTime.now(),
        );
        created.add(match);
        existing.add(match);

        await _notifications.add(
          userId: lost.ownerId,
          type: NotificationType.newMatch,
          title: 'Nouveau match trouvé !',
          body: 'Votre "${lost.title}" correspond à une annonce à '
              '$score% de compatibilité.',
          relatedId: match.id,
        );
        if (found.ownerId != lost.ownerId) {
          await _notifications.add(
            userId: found.ownerId,
            type: NotificationType.newMatch,
            title: 'Nouveau match trouvé !',
            body: 'L\'objet que vous avez trouvé correspond à une '
                'annonce à $score% de compatibilité.',
            relatedId: match.id,
          );
        }
      }
    }

    if (created.isNotEmpty) {
      await _writeAll(existing);
      DataRefreshBus.instance.bump();
    }
    return created;
  }

  @override
  Future<MatchEntity> confirm(String id) async {
    final all = await _readAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) {
      throw StateError('Match $id not found');
    }
    final updated = all[index].copyWith(
      status: MatchStatus.confirmed,
      confirmedAt: DateTime.now(),
    );
    all[index] = updated;
    await _writeAll(all);

    await _itemRepository.markMatched(updated.lostItemId);
    await _itemRepository.markMatched(updated.foundItemId);

    final lost = await _itemRepository.getById(updated.lostItemId);
    final found = await _itemRepository.getById(updated.foundItemId);
    await _notifications.add(
      userId: lost?.ownerId ?? '',
      type: NotificationType.matchConfirmed,
      title: 'Match confirmé !',
      body: 'La vérification pour "${lost?.title ?? 'votre objet'}" a '
          'réussi. Vous pouvez maintenant discuter.',
      relatedId: updated.id,
    );
    if (found != null && found.ownerId != lost?.ownerId) {
      await _notifications.add(
        userId: found.ownerId,
        type: NotificationType.matchConfirmed,
        title: 'Match confirmé !',
        body: 'La restitution de "${lost?.title ?? 'l\'objet'}" a été '
            'confirmée. Vous pouvez maintenant discuter.',
        relatedId: updated.id,
      );
    }

    await _chatRepository.addSystemMessage(
      matchId: updated.id,
      text: 'Le match a été vérifié et confirmé. Vous pouvez maintenant '
          'échanger pour organiser la restitution.',
    );

    DataRefreshBus.instance.bump();
    return updated;
  }

  @override
  Future<MatchEntity> reject(String id) async {
    final all = await _readAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) {
      throw StateError('Match $id not found');
    }
    final updated = all[index].copyWith(status: MatchStatus.rejected);
    all[index] = updated;
    await _writeAll(all);
    DataRefreshBus.instance.bump();
    return updated;
  }
}
