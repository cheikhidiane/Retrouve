import 'package:injectable/injectable.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/storages/json_list_store.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';

@LazySingleton(as: ItemRepository)
class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._store);

  final JsonListStore _store;

  static const _itemsKey = 'items';

  Future<List<ItemEntity>> _readAll() async {
    return _store.readList(_itemsKey).map(ItemEntity.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _writeAll(List<ItemEntity> items) {
    return _store.writeList(_itemsKey, items.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<ItemEntity>> getAll() => _readAll();

  @override
  Future<List<ItemEntity>> getByKind(ItemKind kind) async {
    final all = await _readAll();
    return all.where((item) => item.kind == kind).toList();
  }

  @override
  Future<ItemEntity?> getById(String id) async {
    final all = await _readAll();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<ItemEntity> add(ItemEntity item) async {
    final all = await _readAll();
    all.add(item);
    await _writeAll(all);
    DataRefreshBus.instance.bump();
    return item;
  }

  @override
  Future<void> markMatched(String id, {bool isMatched = true}) async {
    final all = await _readAll();
    final updated = all
        .map((item) =>
            item.id == id ? item.copyWith(isMatched: isMatched) : item)
        .toList();
    await _writeAll(updated);
    DataRefreshBus.instance.bump();
  }
}
