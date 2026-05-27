import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_over_helper.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/promotion_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/wide_game_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/narrow_game_layout.dart';
import 'package:grandmaster_chess/core/providers/ad_provider.dart';

class ChessGamePage extends ConsumerWidget {
  static int _pvpGamesPlayed = 0;

  const ChessGamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);

    ref.listen(chessGameProvider, (previous, next) {
      if (next.pendingPromotion != null && previous?.pendingPromotion == null) {
        PromotionDialog.show(context, next.turn);
      }

      if (next.status != previous?.status) {
        if (next.status == GameStatus.checkmate) {
          final winnerKey = next.turn == PieceColor.white ? 'black_wins' : 'white_wins';
          _handleGameOver(
            context,
            ref,
            next,
            'checkmate'.tr(),
            winnerKey.tr(),
          );
        } else if (next.status == GameStatus.timeout) {
          final winnerKey = next.turn == PieceColor.white ? 'black_wins_time' : 'white_wins_time';
          _handleGameOver(
            context,
            ref,
            next,
            'time_out'.tr(),
            winnerKey.tr(),
          );
        } else if (next.status == GameStatus.draw) {
          _handleGameOver(
            context,
            ref,
            next,
            'draw'.tr(),
            'game_over_draw'.tr(),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          state.gameMode == GameMode.pvp ? 'local_multiplayer'.tr() : 'solo_vs_ai'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.undo_rounded, size: 28.sp),
            tooltip: 'undo_move'.tr(),
            onPressed: () {
              ref.read(chessGameProvider.notifier).undoMove();
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, size: 28.sp),
              tooltip: 'restart_game'.tr(),
              onPressed: () {
                ref.read(chessGameProvider.notifier).initGame(
                      state.gameMode,
                      playerColor: state.playerColor,
                      maxTime: state.maxTime,
                    );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return WideGameLayout(state: state);
            }
            return NarrowGameLayout(state: state);
          },
        ),
      ),
    );
  }

  void _showGameOverAndReport(
    BuildContext context,
    WidgetRef ref,
    GameState state,
    String title,
    String content,
  ) {
    GameOverHelper.showGameOverDialog(
      context,
      ref,
      title,
      content,
      moveRecords: state.moveRecords,
      gameMode: state.gameMode,
      playerColor: state.playerColor,
    );

    // Automatically trigger the report card popup
    if (state.moveRecords.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (context.mounted) {
          GameReportDialog.show(
            context,
            moveRecords: state.moveRecords,
            isVsAi: state.gameMode == GameMode.pva,
            playerColor: state.playerColor,
          );
        }
      });
    }
  }

  void _handleGameOver(
    BuildContext context,
    WidgetRef ref,
    GameState state,
    String title,
    String content,
  ) {
    final mode = state.gameMode;
    if (mode == GameMode.pva) {
      final adService = ref.read(interstitialAdProvider);
      adService.showAd(
        onAdDismissed: () {
          _showGameOverAndReport(context, ref, state, title, content);
        },
      );
    } else if (mode == GameMode.pvp) {
      _pvpGamesPlayed++;
      if (_pvpGamesPlayed % 3 == 0) {
        final adService = ref.read(interstitialAdProvider);
        adService.showAd(
          onAdDismissed: () {
            _showGameOverAndReport(context, ref, state, title, content);
          },
        );
      } else {
        _showGameOverAndReport(context, ref, state, title, content);
      }
    } else {
      _showGameOverAndReport(context, ref, state, title, content);
    }
  }
}
