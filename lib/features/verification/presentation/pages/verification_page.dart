import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/match/domain/repositories/match_repository.dart';
import 'package:template/injector.dart';
import 'package:template/shared/domain/entities/item_entity.dart';
import 'package:template/shared/domain/repositories/item_repository.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/app_avatar.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, this.matchId});

  final String? matchId;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _answerCtrl = TextEditingController();
  bool _isLoading = false;
  ItemEntity? _lostItem;

  @override
  void initState() {
    super.initState();
    _loadLostItem();
  }

  Future<void> _loadLostItem() async {
    final matchId = widget.matchId;
    if (matchId == null) return;
    final match = await getIt<MatchRepository>().getById(matchId);
    if (match == null || !mounted) return;
    final lost = await getIt<ItemRepository>().getById(match.lostItemId);
    if (mounted) setState(() => _lostItem = lost);
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final matchId = widget.matchId;
    final lost = _lostItem;
    if (_answerCtrl.text.isEmpty || matchId == null || lost == null) return;

    setState(() => _isLoading = true);

    final expected = lost.secretAnswer?.trim().toLowerCase() ?? '';
    final given = _answerCtrl.text.trim().toLowerCase();

    if (expected.isNotEmpty && given != expected) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réponse incorrecte. Veuillez réessayer.'),
        ),
      );
      return;
    }

    await getIt<MatchRepository>().confirm(matchId);

    setState(() => _isLoading = false);
    if (!mounted) return;
    // Same branch-awareness as MatchPotentialPage: this route is reused by
    // both Home and Recherche tabs, each with their own `match-confirmed`
    // target so the user stays on the tab they started from.
    final isFromSearch =
        GoRouterState.of(context).name == 'found-verification';
    context.goNamed(
      isFromSearch ? 'found-match-confirmed' : 'match-confirmed',
      extra: matchId,
    );
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
        title: Text('Vérification de légitimité',
            style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _buildShieldBadge(),
            SizedBox(height: 24.h),
            _buildExplanation(),
            SizedBox(height: 28.h),
            _buildParticipants(),
            SizedBox(height: 28.h),
            _buildQuestionCard(),
            SizedBox(height: 32.h),
            AppPrimaryButton(
              label: 'Valider ma réponse',
              onPressed: _answerCtrl.text.isNotEmpty ? _submit : null,
              isLoading: _isLoading,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldBadge() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.teal.withOpacity(0.1),
        border: Border.all(color: AppColor.teal.withOpacity(0.3), width: 2),
      ),
      child: Icon(Icons.shield_outlined, color: AppColor.teal, size: 36.sp),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.teal.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(
            'Prouvez que vous êtes le propriétaire',
            style: AppTextStyle.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Répondez à la question secrète définie lors de votre '
            'déclaration. Votre réponse ne sera pas visible.',
            style: AppTextStyle.bodySmall.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipants() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppAvatar(name: 'Vous', size: 52),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.teal.withOpacity(0.3 + i * 0.3),
                ),
              ),
            ),
          ),
        ),
        const AppAvatar(name: 'Autre utilisateur', size: 52),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final question = _lostItem?.secretQuestion?.isNotEmpty ?? false
        ? _lostItem!.secretQuestion!
        : 'Chargement de la question...';
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColor.teal.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColor.teal.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: AppColor.teal, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text('Question secrète',
                      style: AppTextStyle.labelMedium
                          .copyWith(color: AppColor.teal)),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                question,
                style: AppTextStyle.bodyMedium.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: _answerCtrl,
          label: 'Votre réponse',
          hint: 'Entrez votre réponse ici...',
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline),
          onChanged: (_) => setState(() {}),
          validator: (v) => v == null || v.isEmpty ? 'Réponse requise' : null,
        ),
      ],
    );
  }
}
