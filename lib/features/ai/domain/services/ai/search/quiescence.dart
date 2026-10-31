import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';
import '../evaluation/board_evaluator.dart';
import '../move_generation/move_generator.dart';

/// Quiescence search evaluates only tactical moves (captures/promotions)
/// at the horizon to prevent the "Horizon Effect" without causing runaway search.
class Quiescence {
  static const int _maxQuiescenceDepth = 4;
  static const int _queenDelta = 950;

  final BoardEvaluator _evaluator;
  final MoveGenerator _generator;

  Quiescence(this._evaluator, this._generator);

  int search({
    required SearchState state,
    required int alpha,
    required int beta,
    int qDepth = 0,
  }) {
    final standPat = _evaluator.evaluate(state);

    if (qDepth >= _maxQuiescenceDepth) return standPat;
    if (standPat >= beta) return beta;
    if (standPat > alpha) alpha = standPat;

    // Delta pruning: if standPat + queen value < alpha, even the best capture
    // cannot raise alpha, so prune unless promotions are possible.
    if (standPat + _queenDelta < alpha) return alpha;

    final allMoves = _generator.generateMoves(state);
    final captures = allMoves
        .where((m) => state.board.pieceAt(m.toRow, m.toCol) != null)
        .toList();

    // MVV-LVA sort captures: highest victim value, lowest attacker value first
    captures.sort((a, b) {
      final victimA = state.board.pieceAt(a.toRow, a.toCol);
      final victimB = state.board.pieceAt(b.toRow, b.toCol);
      final valA = _pieceValue(victimA?.type);
      final valB = _pieceValue(victimB?.type);
      return valB.compareTo(valA);
    });

    for (final move in captures) {
      final nextState = _applyMove(state, move);
      final score = -search(
        state: nextState,
        alpha: -beta,
        beta: -alpha,
        qDepth: qDepth + 1,
      );

      if (score >= beta) return beta;
      if (score > alpha) alpha = score;
    }

    return alpha;
  }

  int _pieceValue(PieceType? type) {
    if (type == null) return 0;
    return switch (type) {
      PieceType.pawn => 100,
      PieceType.knight => 320,
      PieceType.bishop => 330,
      PieceType.rook => 500,
      PieceType.queen => 900,
      PieceType.king => 20000,
    };
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
