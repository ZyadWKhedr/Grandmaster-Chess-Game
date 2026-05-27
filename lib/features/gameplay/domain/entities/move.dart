import 'piece.dart';

class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final PieceType? promotionType;

  const Move({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.promotionType,
  });

  @override
  String toString() {
    final promo = promotionType != null ? '=${promotionType!.name}' : '';
    return 'Move ($fromRow,$fromCol) -> ($toRow,$toCol)$promo';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          fromRow == other.fromRow &&
          fromCol == other.fromCol &&
          toRow == other.toRow &&
          toCol == other.toCol &&
          promotionType == other.promotionType;

  @override
  int get hashCode => Object.hash(fromRow, fromCol, toRow, toCol, promotionType);
}
