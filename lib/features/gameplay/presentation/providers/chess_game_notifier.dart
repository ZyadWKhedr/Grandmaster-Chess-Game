import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import 'package:grandmaster_chess/features/gameplay/domain/services/game_timer_service.dart';
import 'package:grandmaster_chess/features/gameplay/domain/services/move_validator.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai/chess_ai_service.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai_trash_talk_service.dart';
import 'package:grandmaster_chess/features/gameplay/domain/services/chess_game_service.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';

class ChessGameNotifier extends StateNotifier<GameState> {
  ChessGameNotifier() : super(GameState.initial());

  final GameTimerService _timerService = GameTimerService();
  final List<GameState> _stateHistory = [];

  final ChessAIService _aiService = ChessAIService();
  late final ChessGameService _gameService = ChessGameService(
    MoveValidator(),
    _aiService,
    AiTrashTalkService(),
  );

  void initGame(
    GameMode mode, {
    PieceColor playerColor = PieceColor.white,
    Difficulty difficulty = Difficulty.intermediate,
    Duration? maxTime,
  }) {
    _timerService.cancel();
    _stateHistory.clear();
    state = GameState.initial(
      mode: mode,
      playerColor: playerColor,
      difficulty: difficulty,
      maxTime: maxTime,
    );

    if (maxTime != null) {
      _startTimer();
    }

    if (mode == GameMode.pva && playerColor == PieceColor.black) {
      _makeAiMove();
    }
  }

  void _startTimer() {
    _timerService.start(
      onTick: () {
        if (state.status != GameStatus.ongoing &&
            state.status != GameStatus.check) {
          _timerService.cancel();
          return;
        }

        final isWhite = state.turn == PieceColor.white;
        final currentTime = isWhite ? state.whiteTime : state.blackTime;
        if (currentTime == null) return;

        final newTime = currentTime - const Duration(seconds: 1);
        if (newTime.inSeconds <= 0) {
          state = isWhite
              ? state.copyWith(whiteTime: Duration.zero, status: GameStatus.timeout)
              : state.copyWith(blackTime: Duration.zero, status: GameStatus.timeout);
          _timerService.cancel();
        } else {
          state = isWhite
              ? state.copyWith(whiteTime: newTime)
              : state.copyWith(blackTime: newTime);
        }
      },
    );
  }

  void selectSquare(int row, int col) {
    if (state.isThinking || _isTerminalStatus(state.status)) return;
    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) return;

    final piece = state.board.pieceAt(row, col);

    if (state.selected?.row == row && state.selected?.col == col) {
      state = state.copyWith(selected: () => null, possibleMoves: []);
      return;
    }

    if (piece != null && piece.color == state.turn) {
      HapticFeedback.lightImpact();
      final moves = _gameService.generateMoves(state, row, col);
      state = state.copyWith(
        selected: () => SquarePosition(row, col),
        possibleMoves: moves,
      );
    }
  }

  void tryMove(int toRow, int toCol) {
    if (state.isThinking || _isTerminalStatus(state.status)) return;
    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) return;

    final selected = state.selected;
    if (selected == null) return;

    final move = Move(
      fromRow: selected.row,
      fromCol: selected.col,
      toRow: toRow,
      toCol: toCol,
    );

    if (!state.possibleMoves.contains(move)) {
      HapticFeedback.heavyImpact();
      return;
    }

    _applyMove(move);
  }

  void promotePiece(PieceType type) {
    var newState = _gameService.promotePiece(state, type);
    newState = newState.copyWith(isThinking: false);
    _handleStateUpdates(newState);
  }

  void _applyMove(Move move) {
    _stateHistory.add(state);
    var newState = _gameService.applyMove(state, move);
    newState = newState.copyWith(isThinking: false);
    _handleStateUpdates(newState);
  }

  void undoMove() {
    if (state.gameMode == GameMode.pva) {
      if (_stateHistory.length >= 2) {
        _stateHistory.removeLast();
        state = _stateHistory.removeLast();
      }
    } else if (_stateHistory.isNotEmpty) {
      state = _stateHistory.removeLast();
    }
  }

  void dismissAiMessage() {
    if (state.aiMessage != null) state = state.copyWith(clearMessage: true);
  }

  void _handleStateUpdates(GameState newState) {
    if (newState.aiMessage != null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) state = state.copyWith(clearMessage: true);
      });
    }

    state = newState;

    if (_isTerminalStatus(state.status)) {
      _timerService.cancel();
      return;
    }

    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      _makeAiMove();
    }
  }

  Future<void> _makeAiMove() async {
    state = state.copyWith(isThinking: true);
    await Future.delayed(const Duration(milliseconds: 300));

    final bestMove = await _aiService.findBestMoveAsync(state);
    if (!mounted) return;

    if (bestMove != null) {
      _applyMove(bestMove);
    } else {
      if (state.isThinking) state = state.copyWith(isThinking: false);
    }
  }

  bool _isTerminalStatus(GameStatus status) =>
      status == GameStatus.checkmate ||
      status == GameStatus.draw ||
      status == GameStatus.timeout;

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
}

final chessGameProvider = StateNotifierProvider<ChessGameNotifier, GameState>(
  (ref) => ChessGameNotifier(),
);
