import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';

class KillerMoves {
  final List<Move?> _killer1 = List.filled(64, null);
  final List<Move?> _killer2 = List.filled(64, null);

  void add(int depth, Move move) {
    if (_killer1[depth] != move) {
      _killer2[depth] = _killer1[depth];
      _killer1[depth] = move;
    }
  }

  int score(int depth, Move move) {
    if (_killer1[depth] == move) return 10000;
    if (_killer2[depth] == move) return 8000;
    return 0;
  }
}