import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/cards/app_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
    return AppCard(
      child: Row(
        children: [
          AppAvatar(name: 'Amadou Diallo', size: 64, showOnline: true, isOnline: true),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amadou Diallo', style: AppTextStyle.headlineMedium),
                SizedBox(height: 4.h),
                Text('amadou@example.com',
                    style: AppTextStyle.bodySmall),
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
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.edit_outlined,
                color: AppColor.textSecondary, size: 20.sp),
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
            value: '12',
            label: 'Déclarations',
            icon: Icons.list_alt,
            color: AppColor.teal,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: '8',
            label: 'Matchs',
            icon: Icons.compare_arrows,
            color: AppColor.appWarning,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: '5',
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
          () => context.go('/search')),
      _MenuItem(Icons.compare_arrows, 'Mes matchs',
          () => context.pushNamed('dashboard')),
      _MenuItem(Icons.notifications_outlined, 'Notifications', () {}),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Icon(item.icon,
                          color: AppColor.textSecondary, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(item.label,
                            style: AppTextStyle.bodyMedium),
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
      onTap: () => context.go('/'),
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
              style: AppTextStyle.labelLarge
                  .copyWith(color: AppColor.appError),
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
          Text(label, style: AppTextStyle.labelSmall, textAlign: TextAlign.center),
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
