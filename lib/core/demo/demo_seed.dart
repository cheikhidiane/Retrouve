import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:uuid/uuid.dart';

/// Seeds a couple of plausible lost/found items on first launch so the
/// found/search list and home feed don't look empty before the presenter
/// starts declaring items live during the demo.
///
/// These seed items belong to a fake "other user" and are intentionally
/// unrelated (different categories/descriptions) to whatever the presenter
/// will declare live, so they never accidentally trigger a confusing extra
/// match during the demo. Real matching magic only happens between items
/// the presenter declares themselves.
Future<void> seedDemoDataIfNeeded() async {
  final itemRepository = getIt<ItemRepository>();
  final existing = await itemRepository.getAll();
  if (existing.isNotEmpty) return;

  const uuid = Uuid();
  const otherUserId = 'demo-seed-user';
  final now = DateTime.now();

  final seedItems = [
    ItemEntity(
      id: uuid.v4(),
      kind: ItemKind.found,
      title: 'Clés de voiture Toyota',
      description: 'Trousseau de clés Toyota avec porte-clés en cuir noir, '
          'trouvé près du parking.',
      category: 'Clés',
      location: 'Université Cheikh Anta Diop',
      date: '${now.day}/${now.month}/${now.year}',
      ownerId: otherUserId,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    ItemEntity(
      id: uuid.v4(),
      kind: ItemKind.found,
      title: 'Sac à dos gris',
      description: 'Sac à dos gris avec quelques cahiers à l\'intérieur, '
          'retrouvé dans une salle de classe.',
      category: 'Sacs',
      location: 'Almadies',
      date: '${now.day}/${now.month}/${now.year}',
      ownerId: otherUserId,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    ItemEntity(
      id: uuid.v4(),
      kind: ItemKind.lost,
      title: 'Montre connectée',
      description: 'Montre connectée noire perdue près du marché.',
      category: 'Autre',
      location: 'Plateau',
      date: '${now.day}/${now.month}/${now.year}',
      ownerId: otherUserId,
      createdAt: now.subtract(const Duration(hours: 6)),
      secretQuestion: 'Quelle est la couleur du bracelet ?',
      secretAnswer: 'noir',
    ),
  ];

  for (final item in seedItems) {
    await itemRepository.add(item);
  }
}
