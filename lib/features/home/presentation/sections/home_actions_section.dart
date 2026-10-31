import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/game_enums.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/chess_game_page.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/home/presentation/providers/match_setup_provider.dart';

/// Primary match launch and resume actions.
class HomeActionsSection extends ConsumerWidget {
  const HomeActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessGameProvider);
    final hasOngoingGame =
        gameState.moveHistory.isNotEmpty && gameState.status == GameStatus.ongoing;

    return Column(
      children: [
        if (hasOngoingGame) ...[
          _buildResumeButton(context, gameState.moveHistory.length),
          SizedBox(height: 10.h),
        ],
        _buildStartButton(context, ref),
      ],
    );
  }

  Widget _buildResumeButton(BuildContext context, int moveCount) {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChessGamePage()),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_fill_rounded,
                    color: AppColors.accentGold, size: 22.sp),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'RESUME MATCH (Move $moveCount)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => _handleStartMatch(context, ref),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24.sp),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'START GAME',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStartMatch(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    final setup = ref.read(matchSetupProvider);

    ref.read(chessGameProvider.notifier).initGame(
      setup.mode,
      playerColor: setup.resolvedColor,
      difficulty: setup.difficulty,
      maxTime: setup.timeLimit,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChessGamePage()),
    );
  }
}
