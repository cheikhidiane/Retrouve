import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template/core/utils/colors.dart';
import 'package:template/core/utils/text_styles.dart';

class MatchScoreBadge extends StatelessWidget {
  const MatchScoreBadge({
    super.key,
    required this.score,
    this.size = 64,
    this.showLabel = true,
  });

  final int score;
  final double size;
  final bool showLabel;

  Color get _color {
    if (score >= 80) return AppColor.teal;
    if (score >= 60) return AppColor.appWarning;
    return AppColor.appError;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.w,
          height: size.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size.w,
                height: size.w,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: _color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                  strokeWidth: 5,
                ),
              ),
              Text(
                '$score%',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: _color,
                  fontWeight: FontWeight.bold,
                  fontSize: (size * 0.26).sp,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: 6.h),
          Text(
            'Compatibilité',
            style: AppTextStyle.labelSmall,
          ),
        ],
      ],
    );
  }
}
