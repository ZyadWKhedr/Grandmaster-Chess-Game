import os
import re

move_map = {
    'features/chess/domain/entities/board.dart': 'features/gameplay/domain/entities/board.dart',
    'features/chess/domain/entities/piece.dart': 'features/gameplay/domain/entities/piece.dart',
    'features/chess/domain/entities/move.dart': 'features/gameplay/domain/entities/move.dart',
    'features/chess/domain/entities/square_position.dart': 'features/gameplay/domain/entities/square_position.dart',
    'features/chess/domain/services/chess_game_service.dart': 'features/gameplay/domain/services/chess_game_service.dart',
    'features/chess/domain/services/move_validator.dart': 'features/gameplay/domain/services/move_validator.dart',
    'features/chess/domain/services/game_timer_service.dart': 'features/gameplay/domain/services/game_timer_service.dart',
    'features/chess/domain/repositories/chess_repository.dart': 'features/gameplay/domain/repositories/chess_repository.dart',
    'features/chess/presentation/pages/chess_game_page.dart': 'features/gameplay/presentation/pages/chess_game_page.dart',
    'features/chess/presentation/widgets/chessboard_widget.dart': 'features/gameplay/presentation/widgets/chessboard_widget.dart',
    'features/chess/presentation/widgets/game_status_widget.dart': 'features/gameplay/presentation/widgets/game_status_widget.dart',
    'features/chess/presentation/widgets/game_timer_widget.dart': 'features/gameplay/presentation/widgets/game_timer_widget.dart',
    'features/chess/presentation/widgets/captured_pieces_widget.dart': 'features/gameplay/presentation/widgets/captured_pieces_widget.dart',
    'features/chess/presentation/widgets/game_over_helper.dart': 'features/gameplay/presentation/widgets/game_over_helper.dart',
    'features/chess/presentation/providers/home/chess_game_notifier.dart': 'features/gameplay/presentation/providers/chess_game_notifier.dart',
    'features/chess/presentation/providers/home/game_state.dart': 'features/gameplay/presentation/providers/game_state.dart',
    'features/chess/presentation/pages/chess_home_page.dart': 'features/home/presentation/pages/chess_home_page.dart',
}

import_regex = re.compile(r"import\s+['\"]package:grandmaster_chess/([^'\"]+)['\"];")

def update_test_imports():
    for root, dirs, files in os.walk('test'):
        for file in files:
            if not file.endswith('.dart'): continue
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                content = f.read()
            
            def replace_match(match):
                imp = match.group(1)
                if imp in move_map:
                    new_resolved = move_map[imp]
                    return f"import 'package:grandmaster_chess/{new_resolved}';"
                return match.group(0)

            new_content = import_regex.sub(replace_match, content)
            
            if new_content != content:
                with open(file_path, 'w') as f:
                    f.write(new_content)

update_test_imports()
