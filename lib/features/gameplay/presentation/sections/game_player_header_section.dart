import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_card.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/captured_pieces_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_timer_widget.dart';

/// Clean player bar displaying name, turn indicator, captured pieces, and timer.
class GamePlayerHeaderSection extends StatelessWidget {
  final PieceColor playerColor;
  final GameState state;
  final bool isTop;

  const GamePlayerHeaderSection({
    super.key,
    required this.playerColor,
    required this.state,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWhite = playerColor == PieceColor.white;
    final isTurn = state.turn == playerColor;
    final time = isWhite ? state.whiteTime : state.blackTime;
    final captured = isWhite ? state.whiteCaptured : state.blackCaptured;

    final title = state.gameMode == GameMode.pva
        ? (isWhite == (state.playerColor == PieceColor.white)
            ? 'you'.tr()
            : 'ai_bot'.tr())
        : (isWhite ? 'white'.tr() : 'black'.tr());

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderColor: isTurn
          ? theme.colorScheme.primary.withValues(alpha: 0.6)
          : null,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTurn ? const Color(0xFF10B981) : Colors.transparent,
                  border: Border.all(
                    color: isTurn ? const Color(0xFF10B981) : Colors.grey,
                    width: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isTurn ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CapturedPiecesWidget(captured: captured),
          ),
          SizedBox(width: 8.w),
          GameTimerWidget(
            time: time,
            isActive: isTurn,
            color: playerColor,
          ),
        ],
      ),
    );
  }
}
