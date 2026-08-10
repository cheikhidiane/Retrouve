import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/cards/item_card.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildTopBar(context),
              SizedBox(height: 20.h),
              _buildGreeting(context),
              SizedBox(height: 24.h),
              Text('Que souhaitez-vous faire ?',
                  style: AppTextStyle.headlineMedium),
              SizedBox(height: 16.h),
              _buildActionCards(context),
              SizedBox(height: 28.h),
              _buildRecentSection(context),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
              name: 'Amadou Diallo',
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

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour, Amadou A. 👋',
                  style: AppTextStyle.headlineLarge),
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
          name: 'Amadou Diallo',
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

  Widget _buildRecentSection(BuildContext context) {
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
                style: AppTextStyle.labelMedium
                    .copyWith(color: AppColor.teal),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockItems.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) {
            final item = _mockItems[i];
            return ItemCard(
              title: item.title,
              category: item.category,
              location: item.location,
              date: item.date,
              type: item.type,
              onTap: () => context.pushNamed(
                'match-potential',
                pathParameters: {'id': '$i'},
              ),
            );
          },
        ),
      ],
    );
  }

  static final _mockItems = [
    _MockItem(
      title: 'iPhone 14 Pro noir',
      category: 'Téléphone',
      location: 'Plateau, Dakar',
      date: 'Hier, 14h30',
      type: ItemType.found,
    ),
    _MockItem(
      title: 'Portefeuille en cuir',
      category: 'Accessoire',
      location: 'Almadies, Dakar',
      date: '23 mai 2026',
      type: ItemType.lost,
    ),
    _MockItem(
      title: 'Clés de voiture Toyota',
      category: 'Clés',
      location: 'Mermoz, Dakar',
      date: '22 mai 2026',
      type: ItemType.found,
    ),
  ];
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

class _MockItem {
  const _MockItem({
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.type,
  });

  final String title;
  final String category;
  final String location;
  final String date;
  final ItemType type;
}
