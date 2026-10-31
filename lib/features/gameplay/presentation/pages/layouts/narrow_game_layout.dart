import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/ai/presentation/widgets/ai_chat_bubble.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/sections/game_board_section.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/sections/game_controls_section.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/sections/game_player_header_section.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_status_widget.dart';

class NarrowGameLayout extends StatelessWidget {
  final GameState state;

  const NarrowGameLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isFlipped = state.playerColor == PieceColor.black;
    final topColor = isFlipped ? PieceColor.white : PieceColor.black;
    final bottomColor = isFlipped ? PieceColor.black : PieceColor.white;

    return Column(
      children: [
        if (state.isThinking)
          const LinearProgressIndicator(minHeight: 2.5),
        GameStatusWidget(turn: state.turn, status: state.status),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GamePlayerHeaderSection(
                  playerColor: topColor,
                  state: state,
                  isTop: true,
                ),
                if (state.gameMode == GameMode.pva && state.aiMessage != null)
                  const AiChatBubble(),
                GameBoardSection(state: state),
                GamePlayerHeaderSection(
                  playerColor: bottomColor,
                  state: state,
                  isTop: false,
                ),
              ],
            ),
          ),
        ),
        GameControlsSection(state: state),
      ],
    );
  }
}
