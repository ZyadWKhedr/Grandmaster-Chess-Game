import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Comparative player score card displayed in the game review header.
class ReportPlayerCard extends StatelessWidget {
  final String title;
  final double accuracy;
  final bool isWhite;

  const ReportPlayerCard({
    super.key,
    required this.title,
    required this.accuracy,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    final color = accuracy >= 85
        ? const Color(0xFF10B981)
        : (accuracy >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return Row(
      mainAxisAlignment: isWhite ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isWhite) ...[
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1.2),
            ),
          ),
          SizedBox(width: 6.w),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isWhite ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                '${accuracy.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (!isWhite) ...[
          SizedBox(width: 6.w),
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              border: Border.all(color: Colors.grey, width: 1.2),
            ),
          ),
        ],
      ],
    );
  }
}

