import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/chessboard_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/captured_pieces_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_status_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_timer_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/evaluation_bar_widget.dart';
import 'package:grandmaster_chess/features/ai/presentation/widgets/ai_chat_bubble.dart';

class NarrowGameLayout extends ConsumerWidget {
  final GameState state;

  const NarrowGameLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFlipped = state.playerColor == PieceColor.black;
    final topCaptured = isFlipped ? state.whiteCaptured : state.blackCaptured;
    final bottomCaptured = isFlipped ? state.blackCaptured : state.whiteCaptured;

    return Column(
      children: [
        if (state.isThinking) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: Column(
            children: [
              GameStatusWidget(turn: state.turn, status: state.status),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(child: CapturedPiecesWidget(captured: topCaptured)),
                    SizedBox(width: 8.w),
                    GameTimerWidget(
                      time: isFlipped ? state.whiteTime : state.blackTime,
                      isActive: state.turn == (isFlipped ? PieceColor.white : PieceColor.black),
                      color: isFlipped ? PieceColor.white : PieceColor.black,
                    ),
                  ],
                ),
              ),
              // Horizontal Evaluation Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 4.h),
                child: SizedBox(
                  height: 12.h,
                  width: double.infinity,
                  child: EvaluationBarWidget(isHorizontal: true, isFlipped: isFlipped),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Full-width chessboard
                          const SizedBox(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ChessBoardWidget(),
                            ),
                          ),
                          if (state.gameMode == GameMode.pva)
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(child: AiChatBubble()),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      icon: Icon(Icons.undo_rounded, size: 20.sp),
                      label: Text(
                        'undo_move'.tr().toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 13.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        ref.read(chessGameProvider.notifier).undoMove();
                      },
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(child: CapturedPiecesWidget(captured: bottomCaptured)),
                    SizedBox(width: 8.w),
                    GameTimerWidget(
                      time: isFlipped ? state.blackTime : state.whiteTime,
                      isActive: state.turn == (isFlipped ? PieceColor.black : PieceColor.white),
                      color: isFlipped ? PieceColor.black : PieceColor.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
