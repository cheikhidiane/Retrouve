import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _features = [
    _FeatureItem(
      icon: Icons.search_rounded,
      title: 'Trouvez & Annoncez',
      description: 'Déclarez un objet perdu ou trouvé en quelques secondes.',
    ),
    _FeatureItem(
      icon: Icons.shield_outlined,
      title: 'Vérification de légitimité',
      description: 'Questions secrètes pour garantir le vrai propriétaire.',
    ),
    _FeatureItem(
      icon: Icons.compare_arrows_rounded,
      title: 'Matching intelligent',
      description: 'Algorithme qui trouve les meilleures correspondances.',
    ),
    _FeatureItem(
      icon: Icons.notifications_outlined,
      title: 'Alertes en temps réel',
      description: 'Soyez notifié dès qu\'un match est trouvé pour vous.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              _buildLogo(),
              SizedBox(height: 40.h),
              Text('Bienvenue 👋', style: AppTextStyle.displayMedium),
              SizedBox(height: 8.h),
              Text(
                'Tout ce dont vous avez besoin pour retrouver vos objets.',
                style: AppTextStyle.bodyMedium
                    .copyWith(color: AppColor.textSecondary),
              ),
              SizedBox(height: 36.h),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _features
                      .map((f) => _FeatureRow(feature: f))
                      .toList(),
                ),
              ),
              SizedBox(height: 32.h),
              _buildStoreButtons(),
              SizedBox(height: 20.h),
              AppPrimaryButton(
                label: 'Créer un compte',
                onPressed: () => context.pushNamed('register'),
              ),
              SizedBox(height: 16.h),
              Center(
                child: GestureDetector(
                  onTap: () => context.pushNamed('login'),
                  child: Text(
                    'Ou je peux passer ainsi',
                    style: AppTextStyle.labelMedium
                        .copyWith(color: AppColor.textMuted),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColor.teal,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Center(
            child: Text(
              'R',
              style: TextStyle(
                color: AppColor.background,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text('Retrouvé', style: AppTextStyle.headlineSmall),
      ],
    );
  }

  Widget _buildStoreButtons() {
    return Row(
      children: [
        Expanded(child: _StoreButton(icon: Icons.apple, label: 'App Store')),
        SizedBox(width: 12.w),
        Expanded(
            child: _StoreButton(icon: Icons.android, label: 'Google Play')),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});
  final _FeatureItem feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppColor.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(feature.icon, color: AppColor.teal, size: 22.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feature.title, style: AppTextStyle.headlineSmall),
              SizedBox(height: 3.h),
              Text(feature.description,
                  style: AppTextStyle.bodySmall.copyWith(height: 1.4)),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: AppColor.teal, size: 18.sp),
      ],
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColor.textSecondary, size: 20.sp),
          SizedBox(width: 8.w),
          Text(label, style: AppTextStyle.labelMedium),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
}
