import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart'; 

import 'core/search_state.dart';
import 'search/iterative_deepening.dart';
import 'evaluation/board_evaluator.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';

class ChessAIService {
  final IterativeDeepening _search =
      IterativeDeepening();

  Move? findBestMove(GameState gameState) {
    final searchState = SearchState(
      board: gameState.board,
      turn: gameState.turn,

      whiteKingSide:
          gameState.canCastleWhiteKingSide,

      whiteQueenSide:
          gameState.canCastleWhiteQueenSide,

      blackKingSide:
          gameState.canCastleBlackKingSide,

      blackQueenSide:
          gameState.canCastleBlackQueenSide,

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

  /// Evaluate the board with full game context (castling rights & en-passant).
  /// Used by move-quality analysis so the evaluator has accurate king-safety
  /// and castling-bonus data — unlike [evaluateBoardState] which uses defaults.
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