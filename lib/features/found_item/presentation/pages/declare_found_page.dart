import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/features/found_item/presentation/blocs/declare_found_cubit.dart';
import 'package:template/injector.dart';
import 'package:template/shared/presentation/blocs/declare_item_state.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';
import 'package:template/shared/presentation/widgets/misc/category_chip.dart';

class DeclareFoundPage extends StatelessWidget {
  const DeclareFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeclareFoundCubit>(),
      child: const _DeclareFoundView(),
    );
  }
}

class _DeclareFoundView extends StatefulWidget {
  const _DeclareFoundView();

  @override
  State<_DeclareFoundView> createState() => _DeclareFoundViewState();
}

class _DeclareFoundViewState extends State<_DeclareFoundView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _storageCtrl = TextEditingController();
  String? _selectedCategory;

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
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _storageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DeclareFoundCubit>().submit(
            description: _descriptionCtrl.text,
            category: _selectedCategory!,
            location: _locationCtrl.text,
            date: _dateCtrl.text.isEmpty
                ? "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"
                : _dateCtrl.text,
            storageLocation: _storageCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeclareFoundCubit, DeclareItemState>(
      listener: (context, state) {
        if (state is DeclareItemSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Annonce publiée avec succès !')),
          );
          context.goNamed('home');
        } else if (state is DeclareItemFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AppScaffold(
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
          title: Text('Publier un objet trouvé',
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
                        controller: _descriptionCtrl,
                        label: 'Description de l\'objet',
                        hint: 'Décrivez ce que vous avez trouvé...',
                        maxLines: 4,
                        minLines: 3,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Description requise'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _locationCtrl,
                        label: 'Lieu où vous l\'avez trouvé',
                        hint: 'ex: Bus DDD, siège arrière',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Lieu requis' : null,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _dateCtrl,
                        label: 'Date de découverte',
                        hint: 'ex: 24 mai 2026',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
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
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _storageCtrl,
                        label: 'Lieu de dépôt',
                        hint: 'ex: Commissariat Plateau, chez moi',
                        prefixIcon:
                            const Icon(Icons.store_mall_directory_outlined),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Lieu de dépôt requis'
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildPhotoSection(),
                      SizedBox(height: 32.h),
                      BlocBuilder<DeclareFoundCubit, DeclareItemState>(
                        builder: (context, state) => AppPrimaryButton(
                          label: 'Soumettre l\'annonce',
                          onPressed: _submit,
                          isLoading: state is DeclareItemLoading,
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo de l\'objet (recommandé)', style: AppTextStyle.labelMedium),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColor.teal.withOpacity(0.3)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: AppColor.teal, size: 32.sp),
                  SizedBox(height: 8.h),
                  Text('Prendre ou choisir une photo',
                      style: AppTextStyle.labelMedium
                          .copyWith(color: AppColor.teal)),
                  SizedBox(height: 4.h),
                  Text('Améliore la précision du matching',
                      style: AppTextStyle.labelSmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
