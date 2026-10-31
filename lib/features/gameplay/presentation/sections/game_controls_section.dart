import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_button.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';

/// Gameplay controls bar providing the undo move action during play,
/// and instant access to the summary report and new match actions upon game conclusion.
class GameControlsSection extends ConsumerWidget {
  final GameState state;

  const GameControlsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGameOver = state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw ||
        state.status == GameStatus.timeout;

    if (isGameOver) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.moveRecords.isNotEmpty) ...[
              Expanded(
                child: AppButton(
                  label: 'view_report'.tr(),
                  icon: Icons.insights_rounded,
                  variant: AppButtonVariant.primary,
                  height: 44.h,
                  onPressed: () => GameReportDialog.show(
                    context,
                    moveRecords: state.moveRecords,
                    isVsAi: state.gameMode == GameMode.pva,
                    playerColor: state.playerColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: AppButton(
                label: 'play_again'.tr(),
                icon: Icons.replay_rounded,
                variant: AppButtonVariant.secondary,
                height: 44.h,
                onPressed: () => ref.read(chessGameProvider.notifier).initGame(
                  state.gameMode,
                  playerColor: state.playerColor,
                  maxTime: state.maxTime,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Center(
        child: AppButton(
          label: 'undo_move'.tr(),
          icon: Icons.undo_rounded,
          variant: AppButtonVariant.secondary,
          height: 44.h,
          onPressed: state.isThinking
              ? null
              : () => ref.read(chessGameProvider.notifier).undoMove(),
        ),
      ),
    );
  }
}
