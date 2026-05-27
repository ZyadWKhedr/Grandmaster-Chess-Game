import 'dart:math';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'search_state.dart';

class Zobrist {
  static final Zobrist _instance = Zobrist._internal();
  factory Zobrist() => _instance;

  // 12 pieces (6 types * 2 colors) * 64 squares
  late final List<List<List<int>>> pieceKeys;
  late final int blackMoveKey;
  late final List<int> castlingKeys; // 16 possible states for 4 booleans
  late final List<int> enPassantKeys; // 8 files

  Zobrist._internal() {
    final random = Random(42); // fixed seed for reproducibility

    int nextRandom64() {
      // Dart's Random.nextInt only returns up to 2^32 - 1.
      // We combine two 32-bit randoms to get a 64-bit integer.
      final a = random.nextInt(1 << 32);
      final b = random.nextInt(1 << 32);
      return (a << 32) | b;
    }

    pieceKeys = List.generate(
      2, // Color
      (_) => List.generate(
        6, // PieceType
        (_) => List.generate(
          64, // Square
          (_) => nextRandom64(),
        ),
      ),
    );

    blackMoveKey = nextRandom64();
    castlingKeys = List.generate(16, (_) => nextRandom64());
    enPassantKeys = List.generate(8, (_) => nextRandom64());
  }

  int getPieceIndex(PieceType type) {
    switch (type) {
      case PieceType.pawn: return 0;
      case PieceType.knight: return 1;
      case PieceType.bishop: return 2;
      case PieceType.rook: return 3;
      case PieceType.queen: return 4;
      case PieceType.king: return 5;
    }
  }

  int getColorIndex(PieceColor color) => color == PieceColor.white ? 0 : 1;

  int computeKey(SearchState state) {
    int key = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = state.board.pieceAt(r, c);
        if (piece != null) {
          int colorIdx = getColorIndex(piece.color);
          int pieceIdx = getPieceIndex(piece.type);
          int squareIdx = r * 8 + c;
          key ^= pieceKeys[colorIdx][pieceIdx][squareIdx];
        }
      }
    }

    if (state.turn == PieceColor.black) {
      key ^= blackMoveKey;
    }

    int castlingIndex = 0;
    if (state.whiteKingSide) castlingIndex |= 1;
    if (state.whiteQueenSide) castlingIndex |= 2;
    if (state.blackKingSide) castlingIndex |= 4;
    if (state.blackQueenSide) castlingIndex |= 8;
    key ^= castlingKeys[castlingIndex];

    if (state.enPassant != null) {
      key ^= enPassantKeys[state.enPassant!.col];
    }

    return key;
  }
}
