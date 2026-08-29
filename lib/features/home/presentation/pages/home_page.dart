import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/events/data_refresh_bus.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/auth/domain/entities/app_user.dart';
import 'package:template/features/auth/domain/repositories/auth_repository.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/cards/item_card.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // The bottom-nav shell keeps this page alive across tab switches
    // (IndexedStack-like), so a bare tab switch won't rerun build() and
    // pick up new data on its own. Listen for repository mutations
    // (declared items, matches, ...) and force a rebuild when they occur.
    DataRefreshBus.instance.version.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    DataRefreshBus.instance.version.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  // Recomputed on every build (not cached) so returning from
  // declare-lost/declare-found (which pop/replace back to this page)
  // always reflects the latest locally persisted data.
  Future<_HomeData> _load() async {
    final user = await getIt<AuthRepository>().getCurrentUser();
    final items = await getIt<ItemRepository>().getAll();
    final matches = await getIt<MatchRepository>().getAll();

    final bestMatchByItemId = <String, MatchEntity>{};
    for (final match in matches) {
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

    return _HomeData(
      user: user,
      recentItems: items.take(5).toList(),
      bestMatchByItemId: bestMatchByItemId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: _load(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final userName = data?.user?.name ?? 'Utilisateur';
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildTopBar(context, userName),
                  SizedBox(height: 20.h),
                  _buildGreeting(context, userName),
                  SizedBox(height: 24.h),
                  Text('Que souhaitez-vous faire ?',
                      style: AppTextStyle.headlineMedium),
                  SizedBox(height: 16.h),
                  _buildActionCards(context),
                  SizedBox(height: 28.h),
                  _buildRecentSection(context, data),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppColor.teal,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'R',
                  style: TextStyle(
                    color: AppColor.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text('Retrouvé', style: AppTextStyle.headlineSmall),
          ],
        ),
        Row(
          children: [
            _iconButton(
              Icons.notifications_outlined,
              () => context.go('/notifications'),
            ),
            SizedBox(width: 8.w),
            AppAvatar(
              name: userName,
              size: 36,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColor.dividerColor),
        ),
        child: Icon(icon, color: AppColor.textSecondary, size: 18.sp),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String userName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour, $userName 👋', style: AppTextStyle.headlineLarge),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: AppColor.teal, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('Dakar, Sénégal',
                      style: AppTextStyle.bodySmall
                          .copyWith(color: AppColor.teal)),
                ],
              ),
            ],
          ),
        ),
        AppAvatar(
          name: userName,
          size: 44,
          showOnline: true,
          isOnline: true,
          onTap: () => context.go('/profile'),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: "J'ai trouvé\nun objet",
            icon: Icons.search_rounded,
            color: AppColor.teal,
            onTap: () => context.pushNamed('declare-found'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ActionCard(
            title: "J'ai perdu\nun objet",
            icon: Icons.report_problem_outlined,
            color: AppColor.appWarning,
            onTap: () => context.pushNamed('declare-lost'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context, _HomeData? data) {
    final items = data?.recentItems ?? const <ItemEntity>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Annonces récentes', style: AppTextStyle.headlineSmall),
            GestureDetector(
              onTap: () => context.go('/search'),
              child: Text(
                'Voir tout',
                style: AppTextStyle.labelMedium.copyWith(color: AppColor.teal),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (data == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColor.teal),
            ),
          )
        else if (items.isEmpty)
          Text(
            'Aucune annonce pour le moment. Déclarez un objet perdu ou '
            'trouvé pour commencer !',
            style:
                AppTextStyle.bodyMedium.copyWith(color: AppColor.textSecondary),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) {
              final item = items[i];
              final match = data.bestMatchByItemId[item.id];
              return ItemCard(
                title: item.title,
                category: item.category,
                location: item.location,
                date: item.date,
                type:
                    item.kind == ItemKind.lost ? ItemType.lost : ItemType.found,
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
      ],
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.user,
    required this.recentItems,
    required this.bestMatchByItemId,
  });

  final AppUser? user;
  final List<ItemEntity> recentItems;
  final Map<String, MatchEntity> bestMatchByItemId;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130.h,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            Text(
              title,
              style: AppTextStyle.headlineSmall.copyWith(height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
