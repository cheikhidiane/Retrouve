import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.isSmall = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isSmall;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8.w : 12.w,
          vertical: isSmall ? 3.h : 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.teal.withOpacity(0.2)
              : AppColor.surfaceLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColor.teal : AppColor.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isSmall ? 12.sp : 14.sp,
                color: isSelected ? AppColor.teal : AppColor.textSecondary,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: (isSmall ? AppTextStyle.labelSmall : AppTextStyle.labelMedium)
                  .copyWith(
                color: isSelected ? AppColor.teal : AppColor.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
