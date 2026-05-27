import os
import re

import_regex1 = re.compile(r"import\s+['\"]../../../entities/(.*?)['\"];")
import_regex2 = re.compile(r"import\s+['\"]../../../domain/entities/(.*?)['\"];")
import_regex3 = re.compile(r"import\s+['\"]../../../../../gameplay/domain/entities/(.*?)['\"];")

def fix_imports():
    for root, dirs, files in os.walk('lib/features/ai'):
        for file in files:
            if not file.endswith('.dart'): continue
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                content = f.read()
            
            content = import_regex1.sub(r"import 'package:grandmaster_chess/features/gameplay/domain/entities/\1';", content)
            content = import_regex2.sub(r"import 'package:grandmaster_chess/features/gameplay/domain/entities/\1';", content)
            content = import_regex3.sub(r"import 'package:grandmaster_chess/features/gameplay/domain/entities/\1';", content)

            with open(file_path, 'w') as f:
                f.write(content)

fix_imports()
