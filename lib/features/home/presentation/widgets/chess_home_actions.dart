// chess_home_actions.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/home/presentation/providers/home_actions_provider.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/home_menu_button.dart';

class ChessHomeActions extends ConsumerWidget {
  const ChessHomeActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        HomeMenuButton(
          label: 'play_vs_friend'.tr(),
          icon: Icons.people,
          mode: GameMode.pvp,
          onTap: () {
            ref.read(homeActionsProvider).startLocalGame(context);
          },
        ),
        const SizedBox(height: 20),
        HomeMenuButton(
          label: 'play_vs_computer'.tr(),
          icon: Icons.computer,
          mode: GameMode.pva,
          onTap: () {
            ref.read(homeActionsProvider).startAiGame(context);
          },
        ),
      ],
    );
  }
}