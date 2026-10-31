import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

/// Interactive card for choosing White or Black army.
class SideOptionCard extends StatelessWidget {
  final PieceColor color;
  final String label;
  final VoidCallback onTap;

  const SideOptionCard({
    super.key,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = color == PieceColor.white;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isWhite
        ? (isDarkTheme ? const Color(0xFF282C3A) : const Color(0xFFF1F5F9))
        : (isDarkTheme ? const Color(0xFF141722) : const Color(0xFF334155));

    final textColor = isWhite
        ? (isDarkTheme ? Colors.white : const Color(0xFF0F172A))
        : Colors.white;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isWhite
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Piece(type: PieceType.king, color: color).render(
                fontSize: 48.sp,
                color: isWhite
                    ? (isDarkTheme ? Colors.white : Colors.black87)
                    : (isDarkTheme ? const Color(0xFFCBD5E1) : Colors.white),
              ),
              SizedBox(height: 12.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

