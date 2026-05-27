class BoardUtils {
  static bool insideBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  static bool isWhiteSquare(int row, int col) {
    return (row + col) % 2 == 0;
  }
}
