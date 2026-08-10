import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.showOnline = false,
    this.isOnline = false,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool showOnline;
  final bool isOnline;
  final VoidCallback? onTap;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.surfaceLight,
              border: Border.all(
                color: AppColor.teal.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (showOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: (size * 0.28).w,
                height: (size * 0.28).w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColor.appSuccess : AppColor.textMuted,
                  border: Border.all(
                    color: AppColor.background,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      color: AppColor.teal.withOpacity(0.2),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColor.teal,
            fontWeight: FontWeight.bold,
            fontSize: (size * 0.35).sp,
          ),
        ),
      ),
    );
  }
}
