import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

import '../core/search_state.dart';

import 'pawn_moves.dart';
import 'knight_moves.dart';
import 'sliding_moves.dart';
import 'king_moves.dart';
import 'legal_move_filter.dart';

class MoveGenerator {
  final PawnMoves _pawnMoves = PawnMoves();
  final KnightMoves _knightMoves = KnightMoves();
  final SlidingMoves _slidingMoves = SlidingMoves();
  final KingMoves _kingMoves = KingMoves();
  final LegalMoveFilter _filter = LegalMoveFilter();

  List<Move> generateMoves(SearchState state) {
    final moves = <Move>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board.pieceAt(row, col);

        if (piece == null) continue;

        if (piece.color != state.turn) continue;

        switch (piece.type) {
          case PieceType.pawn:
            moves.addAll(
              _pawnMoves.generate(
                board: state.board,
                row: row,
                col: col,
                piece: piece,
                enPassant: state.enPassant,
              ),
            );
            break;

          case PieceType.knight:
            moves.addAll(
              _knightMoves.generate(
                board: state.board,
                row: row,
                col: col,
                piece: piece,
              ),
            );
            break;

          case PieceType.bishop:
            moves.addAll(
              _slidingMoves.generateBishopMoves(
                board: state.board,
                row: row,
                col: col,
                piece: piece,
              ),
            );
            break;

          case PieceType.rook:
            moves.addAll(
              _slidingMoves.generateRookMoves(
                board: state.board,
                row: row,
                col: col,
                piece: piece,
              ),
            );
            break;

          case PieceType.queen:
            moves.addAll(
              _slidingMoves.generateQueenMoves(
                board: state.board,
                row: row,
                col: col,
                piece: piece,
              ),
            );
            break;

          case PieceType.king:
            moves.addAll(
              _kingMoves.generate(
                state: state,
                row: row,
                col: col,
                piece: piece,
              ),
            );
            break;
        }
      }
    }

    return _filter.filter(
      board: state.board,
      moves: moves,
      turn: state.turn,
    );
  }
}