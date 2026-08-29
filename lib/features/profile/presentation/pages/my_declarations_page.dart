import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/cards/item_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

/// Shows every lost/found item declared by the current user (unlike
/// `FoundListPage`, which is the public "Recherche" browse-all-found-items
/// tab and never filters by owner).
class MyDeclarationsPage extends StatefulWidget {
  const MyDeclarationsPage({super.key});

  @override
  State<MyDeclarationsPage> createState() => _MyDeclarationsPageState();
}

class _MyDeclarationsPageState extends State<MyDeclarationsPage> {
  List<ItemEntity> _items = [];
  Map<String, MatchEntity> _bestMatchByItemId = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    DataRefreshBus.instance.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    DataRefreshBus.instance.version.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => _load();

  Future<void> _load() async {
    final user = await getIt<AuthRepository>().getCurrentUser();
    final allItems = await getIt<ItemRepository>().getAll();
    final allMatches = await getIt<MatchRepository>().getAll();

    final myItems = user == null
        ? <ItemEntity>[]
        : allItems.where((i) => i.ownerId == user.id).toList();

    final bestMatchByItemId = <String, MatchEntity>{};
    for (final match in allMatches) {
      if (match.status != MatchStatus.potential) continue;
      final currentLost = bestMatchByItemId[match.lostItemId];
      if (currentLost == null || match.score > currentLost.score) {
        bestMatchByItemId[match.lostItemId] = match;
      }
      final currentFound = bestMatchByItemId[match.foundItemId];
      if (currentFound == null || match.score > currentFound.score) {
        bestMatchByItemId[match.foundItemId] = match;
      }
    }

    if (!mounted) return;
    setState(() {
      _items = myItems;
      _bestMatchByItemId = bestMatchByItemId;
      _isLoading = false;
    });
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
        title: Text('Mes déclarations', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.teal))
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      'Vous n\'avez encore rien déclaré.\nUtilisez les '
                      'boutons "J\'ai perdu" ou "J\'ai trouvé" sur l\'accueil.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium
                          .copyWith(color: AppColor.textSecondary),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColor.teal,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final match = _bestMatchByItemId[item.id];
                      return ItemCard(
                        title: item.title,
                        category: item.category,
                        location: item.location,
                        date: item.date,
                        type: item.kind == ItemKind.lost
                            ? ItemType.lost
                            : ItemType.found,
                        matchScore: match?.score,
                        onTap: match == null
                            ? null
                            : () => context.pushNamed(
                                  'match-potential',
                                  pathParameters: {'id': match.id},
                                ),
                      );
                    },
                  ),
                ),
    );
  }
}
