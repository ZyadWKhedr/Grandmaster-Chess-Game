import os

pst_content = """class PieceSquareTables {
  // Simplified PeSTO's Evaluation parameters
  static const List<List<int>> pawnMg = [
      [0,  0,  0,  0,  0,  0,  0,  0],
      [50, 50, 50, 50, 50, 50, 50, 50],
      [10, 10, 20, 30, 30, 20, 10, 10],
      [5,  5, 10, 25, 25, 10,  5,  5],
      [0,  0,  0, 20, 20,  0,  0,  0],
      [5, -5,-10,  0,  0,-10, -5,  5],
      [5, 10, 10,-20,-20, 10, 10,  5],
      [0,  0,  0,  0,  0,  0,  0,  0]
  ];

  static const List<List<int>> knightMg = [
      [-50,-40,-30,-30,-30,-30,-40,-50],
      [-40,-20,  0,  0,  0,  0,-20,-40],
      [-30,  0, 10, 15, 15, 10,  0,-30],
      [-30,  5, 15, 20, 20, 15,  5,-30],
      [-30,  0, 15, 20, 20, 15,  0,-30],
      [-30,  5, 10, 15, 15, 10,  5,-30],
      [-40,-20,  0,  5,  5,  0,-20,-40],
      [-50,-40,-30,-30,-30,-30,-40,-50]
  ];

  static const List<List<int>> bishopMg = [
      [-20,-10,-10,-10,-10,-10,-10,-20],
      [-10,  0,  0,  0,  0,  0,  0,-10],
      [-10,  0,  5, 10, 10,  5,  0,-10],
      [-10,  5,  5, 10, 10,  5,  5,-10],
      [-10,  0, 10, 10, 10, 10,  0,-10],
      [-10, 10, 10, 10, 10, 10, 10,-10],
      [-10,  5,  0,  0,  0,  0,  5,-10],
      [-20,-10,-10,-10,-10,-10,-10,-20]
  ];

  static const List<List<int>> rookMg = [
      [ 0,  0,  0,  0,  0,  0,  0,  0],
      [ 5, 10, 10, 10, 10, 10, 10,  5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [-5,  0,  0,  0,  0,  0,  0, -5],
      [ 0,  0,  0,  5,  5,  0,  0,  0]
  ];

  static const List<List<int>> queenMg = [
      [-20,-10,-10, -5, -5,-10,-10,-20],
      [-10,  0,  0,  0,  0,  0,  0,-10],
      [-10,  0,  5,  5,  5,  5,  0,-10],
      [ -5,  0,  5,  5,  5,  5,  0, -5],
      [  0,  0,  5,  5,  5,  5,  0, -5],
      [-10,  5,  5,  5,  5,  5,  0,-10],
      [-10,  0,  5,  0,  0,  0,  0,-10],
      [-20,-10,-10, -5, -5,-10,-10,-20]
  ];

  static const List<List<int>> kingMg = [
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-30,-40,-40,-50,-50,-40,-40,-30],
      [-20,-30,-30,-40,-40,-30,-30,-20],
      [-10,-20,-20,-20,-20,-20,-20,-10],
      [ 20, 20,  0,  0,  0,  0, 20, 20],
      [ 20, 30, 10,  0,  0, 10, 30, 20]
  ];
}
"""

pst_eval_content = """import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
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
"""

material_eval_content = """import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
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
"""

mobility_eval_content = """import '../core/search_state.dart';
import '../move_generation/move_generator.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class MobilityEvaluator {
  final MoveGenerator _generator = MoveGenerator();

  int evaluate(SearchState state) {
    // Highly simplistic mobility: Number of pseudo-legal moves.
    // Real engines evaluate mobility without full move generation inside evaluation for speed.
    // For this engine, we use a basic approximation or return 0 if performance is critical.
    
    // As generating moves in evaluation is slow, we will return 0 for now to keep the engine fast.
    return 0; 
  }
}
"""

king_safety_content = """import '../core/search_state.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class KingSafetyEvaluator {
  int evaluate(SearchState state) {
    // In a full engine, this evaluates pawn shields and enemy attackers.
    // For this implementation, we return 0 for speed unless fully expanded.
    return 0;
  }
}
"""

board_eval_content = """import '../core/search_state.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'material_evaluator.dart';
import 'pst_evaluator.dart';
import 'mobility_evaluator.dart';
import 'king_safety_evaluator.dart';

class BoardEvaluator {
  final MaterialEvaluator _material = MaterialEvaluator();
  final PSTEvaluator _pst = PSTEvaluator();
  final MobilityEvaluator _mobility = MobilityEvaluator();
  final KingSafetyEvaluator _kingSafety = KingSafetyEvaluator();

  int evaluate(SearchState state) {
    int score = 0;
    
    score += _material.evaluate(state);
    score += _pst.evaluate(state);
    score += _mobility.evaluate(state);
    score += _kingSafety.evaluate(state);

    // Return score from the perspective of the side to move
    return state.turn == PieceColor.white ? score : -score;
  }
}
"""

def write_file(path, content):
    with open(path, 'w') as f:
        f.write(content)

write_file('lib/features/ai/domain/services/ai/utils/piece_square_tables.dart', pst_content)
write_file('lib/features/ai/domain/services/ai/evaluation/pst_evaluator.dart', pst_eval_content)
write_file('lib/features/ai/domain/services/ai/evaluation/material_evaluator.dart', material_eval_content)
write_file('lib/features/ai/domain/services/ai/evaluation/mobility_evaluator.dart', mobility_eval_content)
write_file('lib/features/ai/domain/services/ai/evaluation/king_safety_evaluator.dart', king_safety_content)
write_file('lib/features/ai/domain/services/ai/evaluation/board_evaluator.dart', board_eval_content)
