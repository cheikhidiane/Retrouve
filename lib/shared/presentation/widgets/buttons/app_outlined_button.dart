import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.borderColor,
    this.textColor,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 52.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColor.teal,
          side: BorderSide(
            color: borderColor ?? AppColor.teal,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor ?? AppColor.teal,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      SizedBox(width: 8.w),
                      Text(label,
                          style: AppTextStyle.labelLarge
                              .copyWith(color: textColor ?? AppColor.teal)),
                    ],
                  )
                : Text(
                    label,
                    style: AppTextStyle.labelLarge
                        .copyWith(color: textColor ?? AppColor.teal),
                  ),
      ),
    );
  }
}
