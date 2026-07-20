import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/buttons/app_outlined_button.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC0D1B2A),
                    Color(0xFF0D1B2A),
                  ],
                  stops: [0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildLogo(),
                  const Spacer(),
                  _buildContent(context),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColor.teal,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              'R',
              style: TextStyle(
                color: AppColor.background,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Retrouvé',
          style: AppTextStyle.headlineMedium.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'On se retrouve,\nensemble.',
          style: AppTextStyle.displayLarge,
        ),
        SizedBox(height: 12.h),
        Text(
          'La plateforme qui connecte les personnes ayant perdu leurs objets avec ceux qui les ont trouvés. Vite. En toute confiance.',
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColor.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32.h),
        AppPrimaryButton(
          label: 'Commencer',
          onPressed: () => context.goNamed('onboarding'),
        ),
        SizedBox(height: 12.h),
        AppOutlinedButton(
          label: 'Se connecter',
          onPressed: () => context.pushNamed('login'),
        ),
        SizedBox(height: 24.h),
        Center(
          child: Text(
            'Téléchargez l\'application',
            style: AppTextStyle.labelMedium,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _storeButton(
              icon: Icons.apple,
              label: 'App Store',
            ),
            SizedBox(width: 12.w),
            _storeButton(
              icon: Icons.android,
              label: 'Google Play',
            ),
          ],
        ),
      ],
    );
  }

  Widget _storeButton({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColor.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.textSecondary, size: 18.sp),
          SizedBox(width: 6.w),
          Text(label, style: AppTextStyle.labelMedium),
        ],
      ),
    );
  }
}
