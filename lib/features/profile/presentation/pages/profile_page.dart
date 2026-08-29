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
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/cards/app_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppUser? _user;
  int _declaredCount = 0;
  int _matchesCount = 0;
  int _recoveredCount = 0;
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
    final myItemIds = myItems.map((i) => i.id).toSet();
    final myMatches = allMatches
        .where((m) =>
            myItemIds.contains(m.lostItemId) ||
            myItemIds.contains(m.foundItemId))
        .toList();
    final recovered =
        myMatches.where((m) => m.status == MatchStatus.confirmed).length;

    if (!mounted) return;
    setState(() {
      _user = user;
      _declaredCount = myItems.length;
      _matchesCount = myMatches.length;
      _recoveredCount = recovered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 24.h),
                _buildProfileCard(),
                SizedBox(height: 20.h),
                _buildStatsRow(),
                SizedBox(height: 24.h),
                Text('Mon compte', style: AppTextStyle.headlineSmall),
                SizedBox(height: 12.h),
                _buildMenuItems(context),
                SizedBox(height: 24.h),
                _buildLogoutButton(context),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (context.canPop())
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColor.dividerColor),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColor.textSecondary, size: 16),
            ),
          ),
        Text('Mon profil', style: AppTextStyle.headlineLarge),
      ],
    );
  }

  Widget _buildProfileCard() {
    final name = _user?.name ?? (_isLoading ? '...' : 'Utilisateur');
    final email = _user?.email ?? '';
    return AppCard(
      child: Row(
        children: [
          AppAvatar(name: name, size: 64, showOnline: true, isOnline: true),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyle.headlineMedium),
                SizedBox(height: 4.h),
                Text(email, style: AppTextStyle.bodySmall),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColor.appWarning, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text('4.8', style: AppTextStyle.labelMedium),
                    SizedBox(width: 4.w),
                    Text('· Score de confiance',
                        style: AppTextStyle.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$_declaredCount',
            label: 'Déclarations',
            icon: Icons.list_alt,
            color: AppColor.teal,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: '$_matchesCount',
            label: 'Matchs',
            icon: Icons.compare_arrows,
            color: AppColor.appWarning,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: '$_recoveredCount',
            label: 'Récupérés',
            icon: Icons.check_circle_outline,
            color: AppColor.appSuccess,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem(Icons.list_alt_outlined, 'Mes déclarations',
          () => context.pushNamed('my-declarations')),
      _MenuItem(Icons.compare_arrows, 'Mes matchs',
          () => context.pushNamed('dashboard')),
      _MenuItem(Icons.notifications_outlined, 'Notifications',
          () => context.pushNamed('notifications')),
      _MenuItem(Icons.security_outlined, 'Sécurité & Confidentialité', () {}),
      _MenuItem(Icons.help_outline, 'Aide & Support', () {}),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              GestureDetector(
                onTap: item.onTap,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Icon(item.icon,
                          color: AppColor.textSecondary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(item.label, style: AppTextStyle.bodyMedium),
                      ),
                      Icon(Icons.chevron_right,
                          color: AppColor.textMuted, size: 18.sp),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  color: AppColor.dividerColor,
                  height: 1,
                  indent: 48.w,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await getIt<AuthRepository>().logout();
        if (context.mounted) context.go('/');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColor.appError.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.appError.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppColor.appError, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Se déconnecter',
              style: AppTextStyle.labelLarge.copyWith(color: AppColor.appError),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyle.headlineLarge.copyWith(color: color),
          ),
          SizedBox(height: 2.h),
          Text(label,
              style: AppTextStyle.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
