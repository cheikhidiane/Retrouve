import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/buttons/app_primary_button.dart';
import 'package:template/shared/presentation/widgets/inputs/app_text_field.dart';
import 'package:template/shared/presentation/widgets/layout/app_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildForm(),
                SizedBox(height: 32.h),
                AppPrimaryButton(
                  label: 'Créer mon compte',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 24.h),
                _buildLoginLink(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.dividerColor),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColor.textSecondary, size: 16),
          ),
        ),
        SizedBox(height: 24.h),
        Text('Créer un compte', style: AppTextStyle.displayMedium),
        SizedBox(height: 8.h),
        Text(
          'Rejoignez la communauté Retrouvé.',
          style:
              AppTextStyle.bodyMedium.copyWith(color: AppColor.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        AppTextField(
          controller: _nameCtrl,
          label: 'Nom complet',
          hint: 'Amadou Diallo',
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nom requis';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: _emailCtrl,
          label: 'Email',
          hint: 'votre@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email requis';
            if (!v.contains('@')) return 'Email invalide';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: _phoneCtrl,
          label: 'Téléphone',
          hint: '+221 XX XXX XX XX',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Téléphone requis';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: _passwordCtrl,
          label: 'Mot de passe',
          hint: '••••••••',
          obscureText: _obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: GestureDetector(
            onTap: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          textInputAction: TextInputAction.done,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Mot de passe requis';
            if (v.length < 6) return 'Minimum 6 caractères';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => context.pushNamed('login'),
        child: RichText(
          text: TextSpan(
            style: AppTextStyle.bodyMedium,
            children: [
              const TextSpan(
                text: 'Déjà un compte ? ',
                style: TextStyle(color: AppColor.textSecondary),
              ),
              TextSpan(
                text: 'Se connecter',
                style: TextStyle(
                  color: AppColor.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
