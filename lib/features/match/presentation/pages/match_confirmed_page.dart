import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_outlined_button.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

class MatchConfirmedPage extends StatelessWidget {
  const MatchConfirmedPage({super.key, this.matchId});

  final String? matchId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              _buildSuccessAnimation(),
              SizedBox(height: 32.h),
              Text(
                'Match confirmé !',
                style: AppTextStyle.displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Félicitations ! La vérification a réussi. Vous pouvez '
                'maintenant contacter la personne pour récupérer votre '
                'objet.',
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              _buildInfoCard(),
              const Spacer(),
              AppPrimaryButton(
                label: 'Ouvrir la conversation',
                onPressed: matchId == null
                    ? null
                    : () {
                        // Same branch-awareness: stay on Recherche's chat
                        // route if that's where this confirmation came from.
                        final isFromSearch = GoRouterState.of(context).name ==
                            'found-match-confirmed';
                        context.pushNamed(
                          isFromSearch ? 'found-chat' : 'chat',
                          pathParameters: {'id': matchId!},
                        );
                      },
                icon: const Icon(Icons.chat_bubble_outline,
                    color: AppColor.background),
              ),
              SizedBox(height: 12.h),
              AppOutlinedButton(
                label: 'Retour à l\'accueil',
                onPressed: () => context.goNamed('home'),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.teal.withOpacity(0.1),
        border: Border.all(color: AppColor.teal.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.teal.withOpacity(0.2),
          ),
          child: Icon(
            Icons.check_circle,
            color: AppColor.teal,
            size: 48.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.teal.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _infoRow(Icons.shield_outlined, 'Identité vérifiée',
              'Question secrète validée'),
          Divider(color: AppColor.dividerColor, height: 20.h),
          _infoRow(Icons.star_outline, 'Score de confiance',
              'Utilisateur fiable (4.8/5)'),
          Divider(color: AppColor.dividerColor, height: 20.h),
          _infoRow(Icons.location_on_outlined, 'Lieu de récupération',
              'À définir via la conversation'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColor.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColor.teal, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.headlineSmall),
              Text(subtitle, style: AppTextStyle.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
