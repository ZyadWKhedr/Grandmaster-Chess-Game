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

class ChessGamePage extends ConsumerStatefulWidget {
  static int _pvpGamesPlayed = 0;

  const ChessGamePage({super.key});

  @override
  ConsumerState<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends ConsumerState<ChessGamePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chessGameProvider);

    // Separated listener for promotion dialog
    ref.listen<GameState?>(chessGameProvider, (previous, next) {
      if (next?.pendingPromotion != null &&
          previous?.pendingPromotion == null) {
        PromotionDialog.show(context, next!.turn);
      }
    });

    // Separated listener for game status changes
    ref.listen<GameStatus?>(chessGameProvider.select((state) => state.status), (
      previous,
      next,
    ) {
      if (next != previous && previous != null) {
        _handleGameStatusChange(context, ref, state, next!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          state.gameMode == GameMode.pvp
              ? 'local_multiplayer'.tr()
              : 'solo_vs_ai'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, size: 28.sp),
              tooltip: 'restart_game'.tr(),
              onPressed: () {
                _showRestartConfirmationDialog(context, state);
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

  void _showRestartConfirmationDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28.sp,
              ),
              SizedBox(width: 8.w),
              Text('restart_game'.tr()),
            ],
          ),
          content: Text('are_you_sure_restart'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref
                    .read(chessGameProvider.notifier)
                    .initGame(
                      state.gameMode,
                      playerColor: state.playerColor,
                      maxTime: state.maxTime,
                    );
              },
              child: Text('ok'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _handleGameStatusChange(
    BuildContext context,
    WidgetRef ref,
    GameState state,
    GameStatus status,
  ) {
    String? title;
    String? contentKey;

    switch (status) {
      case GameStatus.checkmate:
        title = 'checkmate'.tr();
        contentKey = state.turn == PieceColor.white
            ? 'black_wins'
            : 'white_wins';
        break;
      case GameStatus.timeout:
        title = 'time_out'.tr();
        contentKey = state.turn == PieceColor.white
            ? 'black_wins_time'
            : 'white_wins_time';
        break;
      case GameStatus.draw:
        title = 'draw'.tr();
        contentKey = 'game_over_draw';
        break;
      default:
        return;
    }

    _handleGameOver(context, ref, state, title, contentKey.tr());
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
      ChessGamePage._pvpGamesPlayed++;
      if (ChessGamePage._pvpGamesPlayed % 3 == 0) {
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
