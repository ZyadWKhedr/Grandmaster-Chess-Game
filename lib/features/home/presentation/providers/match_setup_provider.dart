import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/game_enums.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

/// State representing user selections on the home match configuration panel.
class MatchSetupState {
  final GameMode mode;
  final Difficulty difficulty;
  final PieceColor playerColor;
  final bool isRandomSide;
  final Duration? timeLimit;

  const MatchSetupState({
    this.mode = GameMode.pva,
    this.difficulty = Difficulty.intermediate,
    this.playerColor = PieceColor.white,
    this.isRandomSide = false,
    this.timeLimit = const Duration(minutes: 10),
  });

  /// Computes the effective piece color to start with (resolves random).
  PieceColor get resolvedColor =>
      isRandomSide ? (Random().nextBool() ? PieceColor.white : PieceColor.black) : playerColor;

  MatchSetupState copyWith({
    GameMode? mode,
    Difficulty? difficulty,
    PieceColor? playerColor,
    bool? isRandomSide,
    Duration? Function()? timeLimit,
  }) {
    return MatchSetupState(
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      playerColor: playerColor ?? this.playerColor,
      isRandomSide: isRandomSide ?? this.isRandomSide,
      timeLimit: timeLimit != null ? timeLimit() : this.timeLimit,
    );
  }
}

class MatchSetupNotifier extends Notifier<MatchSetupState> {
  @override
  MatchSetupState build() => const MatchSetupState();

  void setMode(GameMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setDifficulty(Difficulty diff) {
    state = state.copyWith(difficulty: diff);
  }

  void setSide(PieceColor side, {bool isRandom = false}) {
    state = state.copyWith(
      playerColor: side,
      isRandomSide: isRandom,
    );
  }

  void setTimeLimit(Duration? duration) {
    state = state.copyWith(timeLimit: () => duration);
  }
}

final matchSetupProvider =
    NotifierProvider<MatchSetupNotifier, MatchSetupState>(MatchSetupNotifier.new);
