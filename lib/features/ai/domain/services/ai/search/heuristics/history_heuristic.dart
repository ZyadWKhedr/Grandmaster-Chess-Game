import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';

class HistoryHeuristic {
  final Map<String, int> _history = {};

  void add(Move move, int depth) {
    final key = _key(move);
    _history[key] = (_history[key] ?? 0) + depth * depth;
  }

  int score(Move move) {
    return _history[_key(move)] ?? 0;
  }

  String _key(Move m) =>
      '${m.fromRow}${m.fromCol}-${m.toRow}${m.toCol}';
}