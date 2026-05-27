import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';
import '../utils/piece_square_tables.dart';

class PSTEvaluator {
  int evaluate(SearchState state) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = state.board.pieceAt(r, c);
        if (piece != null) {
          // White pieces evaluate from bottom (rank 7) to top (rank 0).
          // PST matrices above are visually structured from White's perspective (index 0 is rank 8 in standard chess).
          int pstRow = piece.color == PieceColor.white ? r : 7 - r;
          int val = _getValue(piece.type, pstRow, c);
          score += (piece.color == PieceColor.white) ? val : -val;
        }
      }
    }
    return score;
  }

  int _getValue(PieceType type, int r, int c) {
    switch (type) {
      case PieceType.pawn: return PieceSquareTables.pawnMg[r][c];
      case PieceType.knight: return PieceSquareTables.knightMg[r][c];
      case PieceType.bishop: return PieceSquareTables.bishopMg[r][c];
      case PieceType.rook: return PieceSquareTables.rookMg[r][c];
      case PieceType.queen: return PieceSquareTables.queenMg[r][c];
      case PieceType.king: return PieceSquareTables.kingMg[r][c];
    }
  }
}
