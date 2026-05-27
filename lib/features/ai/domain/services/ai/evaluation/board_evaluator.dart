import '../core/search_state.dart';
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
