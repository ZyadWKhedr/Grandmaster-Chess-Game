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

class WideGameLayout extends ConsumerWidget {
  final GameState state;

  const WideGameLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFlipped = state.playerColor == PieceColor.black;
    final topCaptured = isFlipped ? state.whiteCaptured : state.blackCaptured;
    final bottomCaptured = isFlipped ? state.blackCaptured : state.whiteCaptured;

    return Column(
      children: [
        if (state.isThinking) const LinearProgressIndicator(minHeight: 2),
        GameStatusWidget(turn: state.turn, status: state.status),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      GameTimerWidget(
                        time: isFlipped ? state.whiteTime : state.blackTime,
                        isActive: state.turn == (isFlipped ? PieceColor.white : PieceColor.black),
                        color: isFlipped ? PieceColor.white : PieceColor.black,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: CapturedPiecesWidget(captured: topCaptured),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                // Evaluation Bar
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: EvaluationBarWidget(isFlipped: isFlipped),
                ),
                SizedBox(width: 10.w),
                // Center Chessboard and Actions Column
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AspectRatio(
                        aspectRatio: 1,
                        child: ChessBoardWidget(),
                      ),
                      SizedBox(height: 12.h),
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
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      GameTimerWidget(
                        time: isFlipped ? state.blackTime : state.whiteTime,
                        isActive: state.turn == (isFlipped ? PieceColor.black : PieceColor.white),
                        color: isFlipped ? PieceColor.black : PieceColor.white,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: CapturedPiecesWidget(captured: bottomCaptured),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
