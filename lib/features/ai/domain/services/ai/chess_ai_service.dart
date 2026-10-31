import 'package:flutter/foundation.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'core/search_state.dart';
import 'search/iterative_deepening.dart';
import 'evaluation/board_evaluator.dart';

/// Parameter wrapper for running AI computations safely in background isolates.
class _AiComputeParams {
  final Board board;
  final PieceColor turn;
  final bool whiteKingSide;
  final bool whiteQueenSide;
  final bool blackKingSide;
  final bool blackQueenSide;
  final SquarePosition? enPassant;
  final Difficulty difficulty;

  const _AiComputeParams({
    required this.board,
    required this.turn,
    required this.whiteKingSide,
    required this.whiteQueenSide,
    required this.blackKingSide,
    required this.blackQueenSide,
    required this.enPassant,
    required this.difficulty,
  });
}

class ChessAIService {
  final IterativeDeepening _search = IterativeDeepening();

  /// Runs the AI search asynchronously in a background Dart isolate using [compute].
  /// This completely prevents UI frame drops, ANR dialogs, and freezes.
  Future<Move?> findBestMoveAsync(GameState gameState) async {
    final params = _AiComputeParams(
      board: gameState.board,
      turn: gameState.turn,
      whiteKingSide: gameState.canCastleWhiteKingSide,
      whiteQueenSide: gameState.canCastleWhiteQueenSide,
      blackKingSide: gameState.canCastleBlackKingSide,
      blackQueenSide: gameState.canCastleBlackQueenSide,
      enPassant: gameState.enPassantTarget,
      difficulty: gameState.aiDifficulty,
    );

    return compute(_isolateSearch, params);
  }

  /// Top-level or static isolate entry point.
  static Move? _isolateSearch(_AiComputeParams params) {
    final searchState = SearchState(
      board: params.board,
      turn: params.turn,
      whiteKingSide: params.whiteKingSide,
      whiteQueenSide: params.whiteQueenSide,
      blackKingSide: params.blackKingSide,
      blackQueenSide: params.blackQueenSide,
      enPassant: params.enPassant,
    );

    return IterativeDeepening()
        .search(state: searchState, difficulty: params.difficulty)
        .bestMove;
  }

  Move? findBestMove(GameState gameState) {
    final searchState = SearchState(
      board: gameState.board,
      turn: gameState.turn,
      whiteKingSide: gameState.canCastleWhiteKingSide,
      whiteQueenSide: gameState.canCastleWhiteQueenSide,
      blackKingSide: gameState.canCastleBlackKingSide,
      blackQueenSide: gameState.canCastleBlackQueenSide,
      enPassant: gameState.enPassantTarget,
    );

    return _search.search(
      state: searchState,
      difficulty: gameState.aiDifficulty,
    ).bestMove;
  }

  int evaluateBoardState(Board board, PieceColor color) {
    final searchState = SearchState(
      board: board,
      turn: color,
      whiteKingSide: false,
      whiteQueenSide: false,
      blackKingSide: false,
      blackQueenSide: false,
      enPassant: null,
    );

    return BoardEvaluator().evaluate(searchState);
  }

  int evaluateBoardStateWithRights(
    Board board,
    PieceColor color, {
    required bool canCastleWKS,
    required bool canCastleWQS,
    required bool canCastleBKS,
    required bool canCastleBQS,
    required SquarePosition? enPassantTarget,
  }) {
    final searchState = SearchState(
      board: board,
      turn: color,
      whiteKingSide: canCastleWKS,
      whiteQueenSide: canCastleWQS,
      blackKingSide: canCastleBKS,
      blackQueenSide: canCastleBQS,
      enPassant: enPassantTarget,
    );

    return BoardEvaluator().evaluate(searchState);
  }
}
