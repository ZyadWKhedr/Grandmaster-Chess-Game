import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
import 'package:grandmaster_chess/core/widgets/app_badge.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

/// Renders captured pieces with an optional point advantage badge.
class CapturedPiecesWidget extends StatelessWidget {
  final List<Piece> captured;
  final int materialAdvantage;

  const CapturedPiecesWidget({
    super.key,
    required this.captured,
    this.materialAdvantage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...captured.map(_buildPiece),
          if (materialAdvantage > 0) ...[
            SizedBox(width: 6.w),
            AppBadge(
              label: '+$materialAdvantage',
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPiece(Piece piece) {
    final double size = switch (piece.type) {
      PieceType.king => 22.sp,
      PieceType.queen => 20.sp,
      PieceType.bishop || PieceType.knight => 18.sp,
      PieceType.rook => 17.sp,
      PieceType.pawn => 14.sp,
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
      child: piece.renderImage(size: size),
    );
  }
}
