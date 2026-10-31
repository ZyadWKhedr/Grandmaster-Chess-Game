import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_button.dart';
import 'package:grandmaster_chess/features/ai/presentation/widgets/ai_chat_bubble.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/chessboard_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/evaluation_bar_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_status_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/sections/game_player_header_section.dart';

class WideGameLayout extends ConsumerWidget {
  final GameState state;

  const WideGameLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFlipped = state.playerColor == PieceColor.black;
    final topColor = isFlipped ? PieceColor.white : PieceColor.black;
    final bottomColor = isFlipped ? PieceColor.black : PieceColor.white;

    return Column(
      children: [
        if (state.isThinking)
          const LinearProgressIndicator(minHeight: 2.5),
        GameStatusWidget(turn: state.turn, status: state.status),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GamePlayerHeaderSection(
                        playerColor: topColor,
                        state: state,
                        isTop: true,
                      ),
                      if (state.gameMode == GameMode.pva &&
                          state.aiMessage != null) ...[
                        SizedBox(height: 8.h),
                        const AiChatBubble(),
                      ],
                      SizedBox(height: 16.h),
                      GamePlayerHeaderSection(
                        playerColor: bottomColor,
                        state: state,
                        isTop: false,
                      ),
                      SizedBox(height: 24.h),
                      if (state.moveRecords.isNotEmpty &&
                          (state.status == GameStatus.checkmate ||
                              state.status == GameStatus.draw ||
                              state.status == GameStatus.timeout)) ...[
                        AppButton(
                          label: 'view_report'.tr(),
                          icon: Icons.insights_rounded,
                          variant: AppButtonVariant.primary,
                          onPressed: () => GameReportDialog.show(
                            context,
                            moveRecords: state.moveRecords,
                            isVsAi: state.gameMode == GameMode.pva,
                            playerColor: state.playerColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      AppButton(
                        label: 'undo_move'.tr(),
                        icon: Icons.undo_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: state.isThinking
                            ? null
                            : () => ref
                                .read(chessGameProvider.notifier)
                                .undoMove(),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: EvaluationBarWidget(isFlipped: isFlipped),
                ),
                SizedBox(width: 16.w),
                const Expanded(
                  flex: 3,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ChessBoardWidget(),
                    ),
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
