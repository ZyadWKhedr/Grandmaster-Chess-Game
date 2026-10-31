/// Tracks board position occurrences along the search branch to detect
/// 3-fold repetition draws without leaking memory across branches.
class RepetitionDetector {
  final Map<int, int> _positions = {};

  void add(int key) {
    _positions[key] = (_positions[key] ?? 0) + 1;
  }

  void remove(int key) {
    final count = _positions[key];
    if (count == null || count <= 1) {
      _positions.remove(key);
    } else {
      _positions[key] = count - 1;
    }
  }

  bool isRepetition(int key) {
    return (_positions[key] ?? 0) >= 2;
  }

  int penalty(int key) {
    final count = _positions[key] ?? 0;
    if (count >= 3) return 100000; // Draw avoidance / checkmate avoidance
    if (count == 2) return 5000;
    return 0;
  }

  void clear() {
    _positions.clear();
  }
}
