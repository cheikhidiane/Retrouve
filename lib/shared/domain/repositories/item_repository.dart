import 'package:template/shared/domain/entities/item_entity.dart';

abstract class ItemRepository {
  Future<List<ItemEntity>> getAll();

  Future<List<ItemEntity>> getByKind(ItemKind kind);

  Future<ItemEntity?> getById(String id);

  Future<ItemEntity> add(ItemEntity item);

  Future<void> markMatched(String id, {bool isMatched = true});
}
