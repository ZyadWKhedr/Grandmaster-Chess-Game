import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

enum SarcasmType {
  userBlunder,
  userGoodMove,
  aiWinning,
  aiLosing,
  check,
  draw,
  generic,
}

class AiTrashTalkService {
  final Random _random = Random();

  String getComment(SarcasmType type) {
    final List<String> keys;

    switch (type) {
      case SarcasmType.userBlunder:
        keys = [
          'trash_user_blunder_1',
          'trash_user_blunder_2',
          'trash_user_blunder_3',
          'trash_user_blunder_4',
          'trash_user_blunder_5',
          'trash_user_blunder_6',
          'trash_user_blunder_7',
          'trash_user_blunder_8',
          'trash_user_blunder_9',
          'trash_user_blunder_10',
          'trash_user_blunder_11',
          'trash_user_blunder_12',
          'trash_user_blunder_13',
          'trash_user_blunder_14',
          'trash_user_blunder_15',
          'trash_user_blunder_16',
          'trash_user_blunder_17',
          'trash_user_blunder_18',
          'trash_user_blunder_19',
          'trash_user_blunder_20',
        ];
        break;
      case SarcasmType.userGoodMove:
        keys = [
          'trash_good_move_1',
          'trash_good_move_2',
          'trash_good_move_3',
          'trash_good_move_4',
          'trash_good_move_5',
          'trash_good_move_6',
          'trash_good_move_7',
          'trash_good_move_8',
          'trash_good_move_9',
          'trash_good_move_10',
          'trash_good_move_11',
          'trash_good_move_12',
          'trash_good_move_13',
          'trash_good_move_14',
          'trash_good_move_15',
          'trash_good_move_16',
          'trash_good_move_17',
          'trash_good_move_18',
        ];
        break;
      case SarcasmType.aiWinning:
        keys = [
          'trash_ai_winning_1',
          'trash_ai_winning_2',
          'trash_ai_winning_3',
          'trash_ai_winning_4',
          'trash_ai_winning_5',
          'trash_ai_winning_6',
          'trash_ai_winning_7',
          'trash_ai_winning_8',
          'trash_ai_winning_9',
          'trash_ai_winning_10',
          'trash_ai_winning_11',
          'trash_ai_winning_12',
          'trash_ai_winning_13',
          'trash_ai_winning_14',
          'trash_ai_winning_15',
          'trash_ai_winning_16',
        ];
        break;
      case SarcasmType.aiLosing:
        keys = [
          'trash_ai_losing_1',
          'trash_ai_losing_2',
          'trash_ai_losing_3',
          'trash_ai_losing_4',
          'trash_ai_losing_5',
          'trash_ai_losing_6',
          'trash_ai_losing_7',
          'trash_ai_losing_8',
          'trash_ai_losing_9',
          'trash_ai_losing_10',
          'trash_ai_losing_11',
          'trash_ai_losing_12',
          'trash_ai_losing_13',
          'trash_ai_losing_14',
          'trash_ai_losing_15',
        ];
        break;
      case SarcasmType.check:
        keys = [
          'trash_check_1',
          'trash_check_2',
          'trash_check_3',
          'trash_check_4',
          'trash_check_5',
          'trash_check_6',
          'trash_check_7',
          'trash_check_8',
          'trash_check_9',
          'trash_check_10',
        ];
        break;
      case SarcasmType.draw:
        keys = [
          'trash_draw_1',
          'trash_draw_2',
          'trash_draw_3',
          'trash_draw_4',
          'trash_draw_5',
          'trash_draw_6',
          'trash_draw_7',
          'trash_draw_8',
        ];
        break;
      case SarcasmType.generic:
        keys = [
          'trash_generic_1',
          'trash_generic_2',
          'trash_generic_3',
          'trash_generic_4',
          'trash_generic_5',
          'trash_generic_6',
          'trash_generic_7',
          'trash_generic_8',
          'trash_generic_9',
          'trash_generic_10',
        ];
        break;
    }

    final selectedKey = keys[_random.nextInt(keys.length)];
    return selectedKey.tr();
  }
}
