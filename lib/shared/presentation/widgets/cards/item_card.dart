import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';
import 'package:template/shared/presentation/widgets/misc/category_chip.dart';

enum ItemType { lost, found }

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.date,
    required this.type,
    this.imageUrl,
    this.onTap,
    this.matchScore,
  });

  final String title;
  final String category;
  final String location;
  final String date;
  final ItemType type;
  final String? imageUrl;
  final VoidCallback? onTap;
  final int? matchScore;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColor.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            _buildImage(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.r),
        bottomLeft: Radius.circular(16.r),
      ),
      child: SizedBox(
        width: 90.w,
        height: 90.h,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColor.surfaceLight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColor.textMuted,
          size: 28.sp,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (matchScore != null) _buildMatchBadge(),
            ],
          ),
          SizedBox(height: 4.h),
          CategoryChip(label: category, isSmall: true),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 12.sp, color: AppColor.textMuted),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyle.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(Icons.access_time_outlined,
                  size: 12.sp, color: AppColor.textMuted),
              SizedBox(width: 2.w),
              Text(date, style: AppTextStyle.labelSmall),
              const Spacer(),
              _buildTypeBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    final isLost = type == ItemType.lost;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isLost
            ? AppColor.appError.withOpacity(0.15)
            : AppColor.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isLost ? 'Perdu' : 'Trouvé',
        style: AppTextStyle.labelSmall.copyWith(
          color: isLost ? AppColor.appError : AppColor.teal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMatchBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColor.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$matchScore%',
        style: AppTextStyle.labelSmall.copyWith(
          color: AppColor.teal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
