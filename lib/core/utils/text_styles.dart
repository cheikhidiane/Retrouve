import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';

class AppTextStyle {
  static TextStyle get displayLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColor.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColor.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColor.textSecondary,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.textSecondary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.textMuted,
      );
}
