import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_outlined_button.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/cards/app_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/match_score_badge.dart';

class MatchPotentialPage extends StatelessWidget {
  const MatchPotentialPage({super.key, this.matchId});

  final String? matchId;

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
        title: Text('Match potentiel !', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _buildMatchHeader(),
            SizedBox(height: 28.h),
            _buildItemsComparison(),
            SizedBox(height: 28.h),
            _buildDetailSection(),
            SizedBox(height: 32.h),
            AppPrimaryButton(
              label: 'Confirmer le match',
              onPressed: () => context.pushNamed('verification'),
            ),
            SizedBox(height: 12.h),
            AppOutlinedButton(
              label: 'Ce n\'est pas mon objet',
              onPressed: () => context.pop(),
              textColor: AppColor.appError,
              borderColor: AppColor.appError,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    return Column(
      children: [
        const MatchScoreBadge(score: 87, size: 80),
        SizedBox(height: 16.h),
        Text(
          'Très bonne correspondance !',
          style: AppTextStyle.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Nous avons trouvé un objet qui correspond à votre déclaration.',
          style: AppTextStyle.bodyMedium
              .copyWith(color: AppColor.textSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildItemsComparison() {
    return Row(
      children: [
        Expanded(
          child: _ItemPreview(
            title: 'Votre déclaration',
            itemName: 'iPhone 14 Pro noir',
            icon: Icons.report_problem_outlined,
            color: AppColor.appWarning,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.teal.withOpacity(0.15),
            ),
            child: Icon(Icons.compare_arrows,
                color: AppColor.teal, size: 18.sp),
          ),
        ),
        Expanded(
          child: _ItemPreview(
            title: 'Objet trouvé',
            itemName: 'iPhone noir, Plateau',
            icon: Icons.search,
            color: AppColor.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails du matching', style: AppTextStyle.headlineSmall),
          SizedBox(height: 16.h),
          _detailRow('Catégorie', 'Téléphone', match: true),
          _divider(),
          _detailRow('Marque', 'Apple iPhone', match: true),
          _divider(),
          _detailRow('Couleur', 'Noir', match: true),
          _divider(),
          _detailRow('Date', '~22 mai', match: false),
          _divider(),
          _detailRow('Lieu', 'Plateau (±2 km)', match: true),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {required bool match}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyle.labelMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: AppTextStyle.bodySmall),
          ),
          Icon(
            match ? Icons.check_circle : Icons.cancel_outlined,
            color: match ? AppColor.teal : AppColor.appWarning,
            size: 18.sp,
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: AppColor.dividerColor, height: 1);
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({
    required this.title,
    required this.itemName,
    required this.icon,
    required this.color,
  });

  final String title;
  final String itemName;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTextStyle.labelSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            itemName,
            style: AppTextStyle.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
