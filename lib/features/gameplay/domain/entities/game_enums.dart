/// Game operating mode.
enum GameMode {
  pvp, // Local multiplayer (Pass & Play)
  pva, // Player vs Computer (AI)
}

/// Terminal and ongoing status of a chess game.
enum GameStatus {
  ongoing,
  check,
  checkmate,
  draw,
  timeout,
}

/// AI search difficulty levels.
enum Difficulty {
  beginner,
  intermediate,
  master,
  grandmaster,
}

