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
}