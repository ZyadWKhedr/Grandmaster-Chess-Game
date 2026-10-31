import 'dart:math' as math;
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

enum MoveQuality { brilliant, good, inaccuracy, mistake, blunder }
enum GamePhase { opening, middlegame, endgame }

class MoveRecord {
  final Move move;
  final PieceColor player;
  final MoveQuality quality;
  final int evalBefore;
  final int evalAfter;
  final bool isSacrifice;

  const MoveRecord({
    required this.move,
    required this.player,
    required this.quality,
    required this.evalBefore,
    required this.evalAfter,
    this.isSacrifice = false,
  });

  /// True delta in centipawns for the moving player (evalAfter - evalBefore).
  /// Note: evalBefore and evalAfter are already evaluated in the moving player's perspective.
  int get delta => evalAfter - evalBefore;

  /// Lichess empirical sigmoid model mapping centipawn evaluation to win probability (0.0 to 100.0).
  static double winP(int centipawns) {
    final cp = centipawns.clamp(-1500, 1500).toDouble();
    return 100.0 / (1.0 + math.exp(-0.00368208 * cp));
  }

  /// Drop in winning expectancy caused by this move (0.0 to 100.0).
  static double winLoss(int evalBefore, int evalAfter) {
    final wb = winP(evalBefore);
    final wa = winP(evalAfter);
    return (wb - wa).clamp(0.0, 100.0);
  }

  /// Move quality classification calibrated on modern Win% loss thresholds.
  static MoveQuality classify(
    int delta, {
    bool isSacrifice = false,
    int? evalBefore,
    int? evalAfter,
    GamePhase phase = GamePhase.middlegame,
  }) {
    if (evalBefore != null && evalAfter != null) {
      final loss = winLoss(evalBefore, evalAfter);
      // Brilliant: tactical piece sacrifice where the player maintains advantage or equality
      if (isSacrifice && loss <= 3.0 && evalAfter >= -100) {
        return MoveQuality.brilliant;
      }
      if (loss <= 8.0) return MoveQuality.good;
      if (loss <= 18.0) return MoveQuality.inaccuracy;
      if (loss <= 30.0) return MoveQuality.mistake;
      return MoveQuality.blunder;
    }

    // Fallback if raw delta only
    if (isSacrifice && delta >= 0) return MoveQuality.brilliant;
    if (delta >= -35) return MoveQuality.good;
    if (delta >= -100) return MoveQuality.inaccuracy;
    if (delta >= -250) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }

  static GamePhase getGamePhase(int moveNumber) {
    if (moveNumber < 15) return GamePhase.opening;
    if (moveNumber < 40) return GamePhase.middlegame;
    return GamePhase.endgame;
  }

  /// Lichess exponential move accuracy formula based on win percentage loss.
  static double moveAccuracy(int evalBefore, int evalAfter, [PieceColor? player]) {
    final loss = winLoss(evalBefore, evalAfter);
    return (103.1668 * math.exp(-0.04354 * loss) - 3.1669).clamp(0.0, 100.0);
  }

  /// Average Centipawn Loss (ACPL) for the given move sequence.
  static double acpl(List<MoveRecord> records) {
    if (records.isEmpty) return 0.0;
    final totalLoss = records.fold<int>(
      0,
      (sum, r) => sum + math.max(0, -r.delta),
    );
    return totalLoss / records.length;
  }

  /// Overall game accuracy score (0.0% - 100.0%) across all player moves.
  static double accuracy(List<MoveRecord> records) {
    if (records.isEmpty) return 100.0;
    double total = 0.0;
    for (final r in records) {
      total += moveAccuracy(r.evalBefore, r.evalAfter);
    }
    return (total / records.length).clamp(0.0, 100.0);
  }

  /// Maps accuracy score to an estimated chess title / performance tier.
  static String performanceTier(double accuracy) {
    if (accuracy >= 92.0) return 'Grandmaster';
    if (accuracy >= 85.0) return 'Master';
    if (accuracy >= 75.0) return 'Expert';
    if (accuracy >= 65.0) return 'Intermediate';
    return 'Casual';
  }

  Map<String, int> getQualityBreakdown(List<MoveRecord> records) {
    final breakdown = {
      'brilliant': 0,
      'good': 0,
      'inaccuracy': 0,
      'mistake': 0,
      'blunder': 0,
    };
    for (final record in records) {
      breakdown[record.quality.name] = (breakdown[record.quality.name] ?? 0) + 1;
    }
    return breakdown;
  }
}
