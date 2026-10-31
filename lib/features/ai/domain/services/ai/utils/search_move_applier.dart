import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import '../core/search_state.dart';

/// Applies a chess move to a SearchState in pure memory.
class SearchMoveApplier {
  static SearchState apply(SearchState state, Move move) {
    final squares = state.board.squares
        .map((r) => List<Piece?>.from(r))
        .toList();

    final movingPiece = squares[move.fromRow][move.fromCol];
    if (movingPiece == null) return state;

    squares[move.toRow][move.toCol] = movingPiece;
    squares[move.fromRow][move.fromCol] = null;

    if (movingPiece.type == PieceType.king) {
      final colDiff = move.toCol - move.fromCol;
      if (colDiff == 2) {
        squares[move.fromRow][5] = squares[move.fromRow][7];
        squares[move.fromRow][7] = null;
      } else if (colDiff == -2) {
        squares[move.fromRow][3] = squares[move.fromRow][0];
        squares[move.fromRow][0] = null;
      }
    }

    SquarePosition? newEnPassant;
    if (movingPiece.type == PieceType.pawn) {
      final rowDiff = move.toRow - move.fromRow;
      final colDiff = move.toCol - move.fromCol;

      if (colDiff != 0 &&
          state.enPassant != null &&
          state.enPassant!.row == move.toRow &&
          state.enPassant!.col == move.toCol) {
        squares[move.fromRow][move.toCol] = null;
      }

      if (rowDiff.abs() == 2) {
        newEnPassant = SquarePosition(
          move.fromRow + (rowDiff ~/ 2),
          move.fromCol,
        );
      }
      if (move.toRow == 0 || move.toRow == 7) {
        squares[move.toRow][move.toCol] = Piece(
          type: PieceType.queen,
          color: movingPiece.color,
        );
      }
    }

    var wks = state.whiteKingSide;
    var wqs = state.whiteQueenSide;
    var bks = state.blackKingSide;
    var bqs = state.blackQueenSide;

    if (movingPiece.type == PieceType.king) {
      if (movingPiece.color == PieceColor.white) {
        wks = false;
        wqs = false;
      } else {
        bks = false;
        bqs = false;
      }
    }
    if (movingPiece.type == PieceType.rook) {
      if (move.fromRow == 7 && move.fromCol == 7) wks = false;
      if (move.fromRow == 7 && move.fromCol == 0) wqs = false;
      if (move.fromRow == 0 && move.fromCol == 7) bks = false;
      if (move.fromRow == 0 && move.fromCol == 0) bqs = false;
    }
    if (move.toRow == 7 && move.toCol == 7) wks = false;
    if (move.toRow == 7 && move.toCol == 0) wqs = false;
    if (move.toRow == 0 && move.toCol == 7) bks = false;
    if (move.toRow == 0 && move.toCol == 0) bqs = false;

    final nextTurn =
        state.turn == PieceColor.white ? PieceColor.black : PieceColor.white;

    return SearchState(
      board: Board(squares),
      turn: nextTurn,
      whiteKingSide: wks,
      whiteQueenSide: wqs,
      blackKingSide: bks,
      blackQueenSide: bqs,
      enPassant: newEnPassant,
    );
  }
}

