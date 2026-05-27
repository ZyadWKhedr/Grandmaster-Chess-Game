import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';

class MaterialEvaluator {
  int evaluate(SearchState state) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = state.board.pieceAt(r, c);
        if (piece != null) {
          int value = _pieceValue(piece.type);
          if (piece.color == PieceColor.white) {
            score += value;
          } else {
            score -= value;
          }
        }
      }
    }
    return score;
  }

  int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn: return 100;
      case PieceType.knight: return 320;
      case PieceType.bishop: return 330;
      case PieceType.rook: return 500;
      case PieceType.queen: return 900;
      case PieceType.king: return 20000;
    }
  }
}
