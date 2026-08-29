import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/cards/item_card.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/category_chip.dart';

class FoundListPage extends StatefulWidget {
  const FoundListPage({super.key});

  @override
  State<FoundListPage> createState() => _FoundListPageState();
}

class _FoundListPageState extends State<FoundListPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  late Future<_FoundListData> _dataFuture;

  static const _categories = [
    'Tout',
    'Téléphones',
    'Portefeuilles',
    'Clés',
    'Sacs',
    'Bijoux',
    'Documents',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
    // See HomePage for why this listener is needed: the shell keeps this
    // page alive across tab switches, so it wouldn't otherwise notice
    // items/matches added from another tab.
    DataRefreshBus.instance.version.addListener(_onDataChanged);
  }

  void _onDataChanged() => _refresh();

  Future<_FoundListData> _load() async {
    final itemRepository = getIt<ItemRepository>();
    final matchRepository = getIt<MatchRepository>();
    final items = await itemRepository.getByKind(ItemKind.found);
    final matches = await matchRepository.getAll();

    final bestMatchByFoundId = <String, MatchEntity>{};
    for (final match in matches) {
      if (match.status != MatchStatus.potential) continue;
      final current = bestMatchByFoundId[match.foundItemId];
      if (current == null || match.score > current.score) {
        bestMatchByFoundId[match.foundItemId] = match;
      }
    }

    return _FoundListData(
      items: items,
      bestMatchByFoundId: bestMatchByFoundId,
    );
  }

  Future<void> _refresh() async {
    final data = await _load();
    if (mounted) setState(() => _dataFuture = Future.value(data));
  }

  @override
  void dispose() {
    DataRefreshBus.instance.version.removeListener(_onDataChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColor.dividerColor),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColor.textSecondary, size: 16),
          ),
        ),
        title: Text('Objets trouvés', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: AppTextField(
              controller: _searchCtrl,
              hint: 'Rechercher un objet...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return CategoryChip(
                  label: cat,
                  isSelected: _selectedCategory == cat ||
                      (cat == 'Tout' && _selectedCategory == null),
                  onTap: () => setState(
                    () => _selectedCategory = cat == 'Tout' ? null : cat,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: FutureBuilder<_FoundListData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.teal),
                  );
                }
                final data = snapshot.data!;
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = data.items.where((item) {
                  final matchesCategory = _selectedCategory == null ||
                      item.category == _selectedCategory;
                  final matchesQuery = query.isEmpty ||
                      item.title.toLowerCase().contains(query) ||
                      item.description.toLowerCase().contains(query);
                  return matchesCategory && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        'Aucun objet trouvé pour le moment.',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMedium
                            .copyWith(color: AppColor.textSecondary),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColor.teal,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final match = data.bestMatchByFoundId[item.id];
                      return ItemCard(
                        title: item.title,
                        category: item.category,
                        location: item.location,
                        date: item.date,
                        type: ItemType.found,
                        matchScore: match?.score,
                        onTap: match == null
                            ? null
                            : () => context.pushNamed(
                                  'found-match',
                                  pathParameters: {'id': match.id},
                                ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundListData {
  const _FoundListData({
    required this.items,
    required this.bestMatchByFoundId,
  });

  final List<ItemEntity> items;
  final Map<String, MatchEntity> bestMatchByFoundId;
}
