import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';
import '../evaluation/board_evaluator.dart';
import '../move_generation/move_generator.dart';

class Quiescence {
  final BoardEvaluator _evaluator;
  final MoveGenerator _generator;

  Quiescence(this._evaluator, this._generator);

  int search({
    required SearchState state,
    required int alpha,
    required int beta,
  }) {
    final standPat = _evaluator.evaluate(state);

    if (standPat >= beta) return beta;
    if (standPat > alpha) alpha = standPat;

    final allMoves = _generator.generateMoves(state);
    final captures = allMoves
        .where((m) => state.board.pieceAt(m.toRow, m.toCol) != null)
        .toList();

    for (final move in captures) {
      final nextState = _applyMove(state, move);
      final score = -search(
        state: nextState,
        alpha: -beta,
        beta: -alpha,
      );

      if (score >= beta) return beta;
      if (score > alpha) alpha = score;
    }

    return alpha;
  }

  SearchState _applyMove(SearchState state, Move move) {
    final squares =
        state.board.squares.map((r) => List<Piece?>.from(r)).toList();
    final movingPiece = squares[move.fromRow][move.fromCol];
    if (movingPiece == null) return state;

    squares[move.toRow][move.toCol] = movingPiece;
    squares[move.fromRow][move.fromCol] = null;

    // En passant capture
    if (movingPiece.type == PieceType.pawn &&
        move.fromCol != move.toCol &&
        state.enPassant != null &&
        state.enPassant!.row == move.toRow &&
        state.enPassant!.col == move.toCol) {
      squares[move.fromRow][move.toCol] = null;
    }

    // Promotion to queen
    if (movingPiece.type == PieceType.pawn &&
        (move.toRow == 0 || move.toRow == 7)) {
      squares[move.toRow][move.toCol] =
          Piece(type: PieceType.queen, color: movingPiece.color);
    }

    final nextTurn =
        state.turn == PieceColor.white ? PieceColor.black : PieceColor.white;

    return SearchState(
      board: Board(squares),
      turn: nextTurn,
      whiteKingSide: state.whiteKingSide,
      whiteQueenSide: state.whiteQueenSide,
      blackKingSide: state.blackKingSide,
      blackQueenSide: state.blackQueenSide,
      enPassant: null,
    );
  }
}
