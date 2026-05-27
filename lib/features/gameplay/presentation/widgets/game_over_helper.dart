import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';

class GameOverHelper {
  static void showGameOverDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String message, {
    List<MoveRecord> moveRecords = const [],
    GameMode gameMode = GameMode.pvp,
    PieceColor playerColor = PieceColor.white,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'game_over'.tr(),
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Column(
                children: [
                  Icon(
                    title.contains('Checkmate') || title.contains('!') && !title.contains('Draw') && !title.contains('Time')
                        ? Icons.emoji_events_rounded
                        : Icons.handshake_rounded,
                    color: Colors.amber,
                    size: 60.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              actions: [
                // View Report button (full width)
                if (moveRecords.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.analytics_rounded),
                        label: Text('view_report'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          GameReportDialog.show(
                            context,
                            moveRecords: moveRecords,
                            isVsAi: gameMode == GameMode.pva,
                            playerColor: playerColor,
                          );
                        },
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(); // Back to home
                        },
                        child: Text(
                          'exit'.tr().toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          final mode = ref.read(chessGameProvider).gameMode;
                          ref.read(chessGameProvider.notifier).initGame(mode);
                        },
                        child: Text(
                          'play_again'.tr().toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
