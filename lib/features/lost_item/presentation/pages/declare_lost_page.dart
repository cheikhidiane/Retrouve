import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/category_chip.dart';

class DeclareLostPage extends StatefulWidget {
  const DeclareLostPage({super.key});

  @override
  State<DeclareLostPage> createState() => _DeclareLostPageState();
}

class _DeclareLostPageState extends State<DeclareLostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _secretQuestionCtrl = TextEditingController();
  final _secretAnswerCtrl = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  static const _categories = [
    'Téléphones',
    'Portefeuilles',
    'Clés',
    'Sacs',
    'Bijoux',
    'Documents',
    'Autre',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _secretQuestionCtrl.dispose();
    _secretAnswerCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.goNamed('home');
        }
      });
    }
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
        title: Text('Déclarer un objet perdu',
            style: AppTextStyle.headlineSmall),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCategoryBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    AppTextField(
                      controller: _titleCtrl,
                      label: 'Titre de l\'annonce',
                      hint: 'ex: iPhone 14 Pro noir',
                      prefixIcon: const Icon(Icons.title),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Titre requis' : null,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _descriptionCtrl,
                      label: 'Description',
                      hint:
                          'Décrivez l\'objet en détail (couleur, marque, état...)',
                      maxLines: 4,
                      minLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Description requise' : null,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _locationCtrl,
                      label: 'Lieu approximatif de perte',
                      hint: 'ex: Plateau, près de la gare',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Lieu requis' : null,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _dateCtrl,
                      label: 'Date de perte',
                      hint: 'ex: 24 mai 2026',
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColor.teal,
                                surface: AppColor.surface,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          _dateCtrl.text =
                              '${picked.day}/${picked.month}/${picked.year}';
                        }
                      },
                    ),
                    SizedBox(height: 28.h),
                    _buildSecretSection(),
                    SizedBox(height: 32.h),
                    AppPrimaryButton(
                      label: 'Publier l\'annonce',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.background,
        border: Border(
          bottom: BorderSide(color: AppColor.dividerColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: _categories.map((cat) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: CategoryChip(
                label: cat,
                isSelected: _selectedCategory == cat,
                onTap: () => setState(() => _selectedCategory = cat),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSecretSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColor.teal, size: 18.sp),
            SizedBox(width: 8.w),
            Text('Saisir les détails importants',
                style: AppTextStyle.headlineSmall),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          'Ces informations permettront de vérifier que vous êtes bien le propriétaire.',
          style: AppTextStyle.bodySmall.copyWith(height: 1.5),
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: _secretQuestionCtrl,
          label: 'Question secrète',
          hint: 'ex: Quelle est la dernière app ouverte ?',
          validator: (v) =>
              v == null || v.isEmpty ? 'Question requise' : null,
        ),
        SizedBox(height: 12.h),
        AppTextField(
          controller: _secretAnswerCtrl,
          label: 'Réponse secrète',
          hint: 'Votre réponse',
          obscureText: true,
          suffixIcon: const Icon(Icons.lock_outline),
          validator: (v) =>
              v == null || v.isEmpty ? 'Réponse requise' : null,
        ),
      ],
    );
  }
}
