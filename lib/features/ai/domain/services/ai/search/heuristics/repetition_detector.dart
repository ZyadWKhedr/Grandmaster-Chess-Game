class RepetitionDetector {
  final Map<String, int> positions = {};

  void add(String key) {
    positions[key] = (positions[key] ?? 0) + 1;
  }

  bool isRepetition(String key) {
    return (positions[key] ?? 0) >= 2;
  }

  int penalty(String key) {
    final count = positions[key] ?? 0;
    if (count >= 3) return 100000; // draw avoidance
    if (count == 2) return 5000;
    return 0;
  }
}