import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/core/providers/ad_provider.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_over_helper.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/promotion_dialog.dart';

final gameCoordinatorProvider = Provider<GameCoordinator>((ref) {
  return GameCoordinator(ref);
});

/// Coordinates gameplay UI events: modal dialogs, status alerts, and ad displays.
class GameCoordinator {
  final Ref _ref;
  int _pvpGamesPlayed = 0;

  GameCoordinator(this._ref);

  void handlePromotion(BuildContext context, GameState state) {
    PromotionDialog.show(context, state.turn);
  }

  void handleStatusChange(
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

  void _handleGameOver(
    BuildContext context,
    WidgetRef ref,
    GameState state,
    String title,
    String content,
  ) {
    final mode = state.gameMode;
    final adService = _ref.read(interstitialAdProvider);

    if (mode == GameMode.pva) {
      adService.showAd(
        onAdDismissed: () =>
            _showGameOver(context, ref, state, title, content),
      );
    } else if (mode == GameMode.pvp) {
      _pvpGamesPlayed++;
      if (_pvpGamesPlayed % 3 == 0) {
        adService.showAd(
          onAdDismissed: () =>
              _showGameOver(context, ref, state, title, content),
        );
      } else {
        _showGameOver(context, ref, state, title, content);
      }
    } else {
      _showGameOver(context, ref, state, title, content);
    }
  }

  void _showGameOver(
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
  }
}

