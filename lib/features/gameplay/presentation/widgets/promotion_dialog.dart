import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';

import '../../../../core/extensions/piece_symbol.dart';

class PromotionDialog extends ConsumerWidget {
  final PieceColor color;

  const PromotionDialog({super.key, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('promote_pawn'.tr()),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight,
        ].map((type) {
          final piece = Piece(type: type, color: color);
          return GestureDetector(
            onTap: () {
              ref.read(chessGameProvider.notifier).promotePiece(type);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: piece.render(fontSize: 40.sp),
            ),
          );
        }).toList(),
      ),
    );
  }

  static void show(BuildContext context, PieceColor color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PromotionDialog(color: color),
    );
  }
}
