import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';

class SearchState {
  final Board board;
  final PieceColor turn;
  final bool whiteKingSide;
  final bool whiteQueenSide;
  final bool blackKingSide;
  final bool blackQueenSide;
  final SquarePosition? enPassant;

  const SearchState({
    required this.board,
    required this.turn,
    required this.whiteKingSide,
    required this.whiteQueenSide,
    required this.blackKingSide,
    required this.blackQueenSide,
    // nullable but explicitly required so callers are forced to think about it
    required this.enPassant,
  });

  /// Use [clearEnPassant] = true to explicitly set enPassant to null.
  SearchState copyWith({
    Board? board,
    PieceColor? turn,
    bool? whiteKingSide,
    bool? whiteQueenSide,
    bool? blackKingSide,
    bool? blackQueenSide,
    SquarePosition? enPassant,
    bool clearEnPassant = false,
  }) {
    return SearchState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      whiteKingSide: whiteKingSide ?? this.whiteKingSide,
      whiteQueenSide: whiteQueenSide ?? this.whiteQueenSide,
      blackKingSide: blackKingSide ?? this.blackKingSide,
      blackQueenSide: blackQueenSide ?? this.blackQueenSide,
      enPassant: clearEnPassant ? null : (enPassant ?? this.enPassant),
    );
  }
}