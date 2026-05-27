import os
import re
import shutil

# Map of old absolute paths (relative to lib/) to new absolute paths
move_map = {
    # Splash
    'features/chess/presentation/pages/splash_screen.dart': 'features/splash/presentation/pages/splash_screen.dart',
    'features/chess/presentation/widgets/splash_logo_widget.dart': 'features/splash/presentation/widgets/splash_logo_widget.dart',
    'features/chess/presentation/widgets/splash_title_widget.dart': 'features/splash/presentation/widgets/splash_title_widget.dart',
    'features/chess/presentation/widgets/splash_loading_widget.dart': 'features/splash/presentation/widgets/splash_loading_widget.dart',
    'features/chess/presentation/providers/splash/splash_notifier.dart': 'features/splash/presentation/providers/splash_notifier.dart',
    'features/chess/presentation/providers/splash/splash_state.dart': 'features/splash/presentation/providers/splash_state.dart',

    # Home
    'features/chess/presentation/pages/chess_home_page.dart': 'features/home/presentation/pages/chess_home_page.dart',
    'features/chess/presentation/widgets/home_logo.dart': 'features/home/presentation/widgets/home_logo.dart',
    'features/chess/presentation/widgets/home_menu_button.dart': 'features/home/presentation/widgets/home_menu_button.dart',
    'features/chess/presentation/widgets/chess_home_actions.dart': 'features/home/presentation/widgets/chess_home_actions.dart',
    'features/chess/presentation/widgets/chess_home_app_bar.dart': 'features/home/presentation/widgets/chess_home_app_bar.dart',
    'features/chess/presentation/widgets/banner_ad_widget.dart': 'features/home/presentation/widgets/banner_ad_widget.dart',
    'features/chess/presentation/widgets/side_selection_dialog.dart': 'features/home/presentation/widgets/side_selection_dialog.dart',
    'features/chess/presentation/widgets/timer_selection_dialog.dart': 'features/home/presentation/widgets/timer_selection_dialog.dart',
    'features/chess/presentation/widgets/difficulty_selection_dialog.dart': 'features/home/presentation/widgets/difficulty_selection_dialog.dart',
    'features/chess/presentation/providers/home/home_actions_provider.dart': 'features/home/presentation/providers/home_actions_provider.dart',

    # Settings
    'features/chess/presentation/pages/settings/settings_page.dart': 'features/settings/presentation/pages/settings_page.dart',
    'features/chess/presentation/pages/settings/language_page.dart': 'features/settings/presentation/pages/language_page.dart',
    'features/chess/presentation/widgets/settings/settings_tile.dart': 'features/settings/presentation/widgets/settings_tile.dart',
    'features/chess/presentation/widgets/settings/theme_settings_tile.dart': 'features/settings/presentation/widgets/theme_settings_tile.dart',
    'features/chess/presentation/widgets/settings/language_setting_tile.dart': 'features/settings/presentation/widgets/language_setting_tile.dart',
    'features/chess/presentation/widgets/settings/about_setting_tile.dart': 'features/settings/presentation/widgets/about_setting_tile.dart',
    'features/chess/presentation/widgets/settings/portfolio_setting_tile.dart': 'features/settings/presentation/widgets/portfolio_setting_tile.dart',
    'features/chess/presentation/widgets/settings/settings_sheet.dart': 'features/settings/presentation/widgets/settings_sheet.dart',
    'features/chess/presentation/providers/settings/settings_provider.dart': 'features/settings/presentation/providers/settings_provider.dart',
    'features/chess/presentation/providers/theme/theme_provider.dart': 'features/settings/presentation/providers/theme_provider.dart',

    # Gameplay
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

    # AI
    'features/chess/domain/services/chess_ai_service.dart': 'features/ai/domain/services/chess_ai_service.dart',
    'features/chess/domain/services/ai_trash_talk_service.dart': 'features/ai/domain/services/ai_trash_talk_service.dart',
    'features/chess/presentation/widgets/ai_chat_bubble.dart': 'features/ai/presentation/widgets/ai_chat_bubble.dart',
}

def resolve_path(base_file_path, import_str):
    if import_str.startswith('package:grandmaster_chess/'):
        return import_str.replace('package:grandmaster_chess/', '')
    
    # Relative path
    base_dir = os.path.dirname(base_file_path)
    parts = base_dir.split('/')
    
    import_parts = import_str.split('/')
    for p in import_parts:
        if p == '.':
            continue
        elif p == '..':
            if parts:
                parts.pop()
        else:
            parts.append(p)
    return '/'.join(parts)

import_regex = re.compile(r"import\s+['\"]([^'\"]+)['\"];")
part_regex = re.compile(r"part\s+['\"]([^'\"]+)['\"];")

def update_imports():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if not file.endswith('.dart'): continue
            file_path = os.path.join(root, file)
            # relative to lib
            rel_file_path = os.path.relpath(file_path, 'lib')
            
            with open(file_path, 'r') as f:
                content = f.read()
            
            def replace_match(match):
                imp = match.group(1)
                # Ignore dart: imports and other packages
                if imp.startswith('dart:') or (imp.startswith('package:') and not imp.startswith('package:grandmaster_chess/')):
                    return match.group(0)
                
                resolved = resolve_path(rel_file_path, imp)
                
                # Check if it was moved
                if resolved in move_map:
                    new_resolved = move_map[resolved]
                    return f"import 'package:grandmaster_chess/{new_resolved}';"
                else:
                    # If it wasn't moved, but it is an absolute package import, we should just keep it
                    if imp.startswith('package:grandmaster_chess/'):
                        return match.group(0)
                    
                    # If it's a relative import, and the CURRENT file is being moved, 
                    # we should also rewrite it to an absolute package import to be safe
                    if rel_file_path in move_map:
                        return f"import 'package:grandmaster_chess/{resolved}';"
                    
                    return match.group(0)

            new_content = import_regex.sub(replace_match, content)
            
            # parts are always relative to current file, don't change to package: unless required.
            # But we must update parts if we move them! Let's ignore parts for now since none are moved or we don't have parts.
            
            if new_content != content:
                with open(file_path, 'w') as f:
                    f.write(new_content)

update_imports()

# Move files
for old_path, new_path in move_map.items():
    old_full = os.path.join('lib', old_path)
    new_full = os.path.join('lib', new_path)
    if os.path.exists(old_full):
        os.makedirs(os.path.dirname(new_full), exist_ok=True)
        shutil.move(old_full, new_full)
        print(f"Moved {old_path} -> {new_path}")
    else:
        print(f"Could not find {old_full}")

# Remove old empty directories
for root, dirs, files in os.walk('lib/features/chess', topdown=False):
    if not os.listdir(root):
        os.rmdir(root)
print("Done")
