import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/entities/match_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/buttons/app_outlined_button.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/cards/app_card.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/match_score_badge.dart';

class MatchPotentialPage extends StatefulWidget {
  const MatchPotentialPage({super.key, this.matchId});

  final String? matchId;

  @override
  State<MatchPotentialPage> createState() => _MatchPotentialPageState();
}

class _MatchPotentialPageState extends State<MatchPotentialPage> {
  late Future<_MatchData?> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<_MatchData?> _load() async {
    final matchId = widget.matchId;
    if (matchId == null) return null;

    final matchRepository = getIt<MatchRepository>();
    final itemRepository = getIt<ItemRepository>();

    final match = await matchRepository.getById(matchId);
    if (match == null) return null;

    final lost = await itemRepository.getById(match.lostItemId);
    final found = await itemRepository.getById(match.foundItemId);
    if (lost == null || found == null) return null;

    return _MatchData(match: match, lost: lost, found: found);
  }

  Future<void> _reject() async {
    final matchId = widget.matchId;
    if (matchId != null) {
      await getIt<MatchRepository>().reject(matchId);
    }
    if (mounted) context.pop();
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
        title: Text('Match potentiel !', style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: FutureBuilder<_MatchData?>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Text(
                  'Ce match n\'existe plus ou a été traité.',
                  style: AppTextStyle.bodyMedium
                      .copyWith(color: AppColor.textSecondary),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColor.teal),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                _buildMatchHeader(data.match.score),
                SizedBox(height: 28.h),
                _buildItemsComparison(data),
                SizedBox(height: 28.h),
                _buildDetailSection(data),
                SizedBox(height: 32.h),
                AppPrimaryButton(
                  label: 'Confirmer le match',
                  onPressed: () {
                    // This page is reused by both the Home and Recherche
                    // tabs (each with its own nested `verification` route
                    // so confirming a match doesn't silently switch tabs).
                    final isFromSearch =
                        GoRouterState.of(context).name == 'found-match';
                    context.pushNamed(
                      isFromSearch ? 'found-verification' : 'verification',
                      pathParameters: {'id': data.match.id},
                    );
                  },
                ),
                SizedBox(height: 12.h),
                AppOutlinedButton(
                  label: 'Ce n\'est pas mon objet',
                  onPressed: _reject,
                  textColor: AppColor.appError,
                  borderColor: AppColor.appError,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchHeader(int score) {
    final label = score >= 75
        ? 'Très bonne correspondance !'
        : score >= 50
            ? 'Bonne correspondance'
            : 'Correspondance possible';
    return Column(
      children: [
        MatchScoreBadge(score: score, size: 80),
        SizedBox(height: 16.h),
        Text(
          label,
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

  Widget _buildItemsComparison(_MatchData data) {
    return Row(
      children: [
        Expanded(
          child: _ItemPreview(
            title: 'Votre déclaration',
            itemName: data.lost.title,
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
            child:
                Icon(Icons.compare_arrows, color: AppColor.teal, size: 18.sp),
          ),
        ),
        Expanded(
          child: _ItemPreview(
            title: 'Objet trouvé',
            itemName: '${data.found.title}, ${data.found.location}',
            icon: Icons.search,
            color: AppColor.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(_MatchData data) {
    final lost = data.lost;
    final found = data.found;
    final categoryMatch =
        lost.category.toLowerCase() == found.category.toLowerCase();
    final locationMatch = lost.location
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .any((w) => w.length > 2 && found.location.toLowerCase().contains(w));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Détails du matching', style: AppTextStyle.headlineSmall),
          SizedBox(height: 16.h),
          _detailRow('Catégorie', found.category, match: categoryMatch),
          _divider(),
          _detailRow('Date signalée', '${lost.date} / ${found.date}',
              match: lost.date == found.date),
          _divider(),
          _detailRow('Lieu', found.location, match: locationMatch),
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

class _MatchData {
  const _MatchData({
    required this.match,
    required this.lost,
    required this.found,
  });

  final MatchEntity match;
  final ItemEntity lost;
  final ItemEntity found;
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
