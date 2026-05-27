import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class LegalMoveFilter {
  List<Move> filter({
    required Board board,
    required List<Move> moves,
    required PieceColor turn,
  }) {
    final legal = <Move>[];
    for (final move in moves) {
      final newBoard = _applyMove(board, move);
      if (!_isKingInCheck(newBoard, turn)) {
        legal.add(move);
      }
    }
    return legal;
  }

  Board _applyMove(Board board, Move move) {
    final copy = board.squares.map((row) => List<Piece?>.from(row)).toList();
    copy[move.toRow][move.toCol] = copy[move.fromRow][move.fromCol];
    copy[move.fromRow][move.fromCol] = null;
    return Board(copy);
  }

  bool _isKingInCheck(Board board, PieceColor kingColor) {
    int kingRow = -1, kingCol = -1;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p?.type == PieceType.king && p?.color == kingColor) {
          kingRow = r;
          kingCol = c;
          break;
        }
      }
      if (kingRow != -1) break;
    }

    if (kingRow == -1) return true;
    return _isSquareAttacked(board, kingRow, kingCol, kingColor);
  }

  bool _isSquareAttacked(Board board, int row, int col, PieceColor kingColor) {
    final enemy = kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Pawn attacks
    final pawnDir = kingColor == PieceColor.white ? -1 : 1;
    for (final dc in [-1, 1]) {
      final pr = row + pawnDir;
      final pc = col + dc;
      if (_inBounds(pr, pc)) {
        final p = board.pieceAt(pr, pc);
        if (p != null && p.color == enemy && p.type == PieceType.pawn) return true;
      }
    }

    // Knight attacks
    const knightOffsets = [
      (-2, -1), (-2, 1), (-1, -2), (-1, 2),
      (1, -2),  (1, 2),  (2, -1),  (2, 1),
    ];
    for (final (dr, dc) in knightOffsets) {
      final r = row + dr;
      final c = col + dc;
      if (_inBounds(r, c)) {
        final p = board.pieceAt(r, c);
        if (p != null && p.color == enemy && p.type == PieceType.knight) return true;
      }
    }

    // King attacks (adjacent)
    const kingOffsets = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),            (0, 1),
      (1, -1),  (1, 0),  (1, 1),
    ];
    for (final (dr, dc) in kingOffsets) {
      final r = row + dr;
      final c = col + dc;
      if (_inBounds(r, c)) {
        final p = board.pieceAt(r, c);
        if (p != null && p.color == enemy && p.type == PieceType.king) return true;
      }
    }

    // Diagonal (bishop / queen)
    const diagDirs = [(-1, -1), (-1, 1), (1, -1), (1, 1)];
    for (final (dr, dc) in diagDirs) {
      int r = row + dr;
      int c = col + dc;
      while (_inBounds(r, c)) {
        final p = board.pieceAt(r, c);
        if (p != null) {
          if (p.color == enemy &&
              (p.type == PieceType.bishop || p.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        r += dr;
        c += dc;
      }
    }

    // Straight (rook / queen)
    const straightDirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dr, dc) in straightDirs) {
      int r = row + dr;
      int c = col + dc;
      while (_inBounds(r, c)) {
        final p = board.pieceAt(r, c);
        if (p != null) {
          if (p.color == enemy &&
              (p.type == PieceType.rook || p.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        r += dr;
        c += dc;
      }
    }

    return false;
  }

  bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
}