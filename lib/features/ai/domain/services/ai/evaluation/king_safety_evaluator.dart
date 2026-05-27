import '../core/search_state.dart';

class KingSafetyEvaluator {
  int evaluate(SearchState state) {
    // In a full engine, this evaluates pawn shields and enemy attackers.
    // For this implementation, we return 0 for speed unless fully expanded.
    return 0;
  }
}
