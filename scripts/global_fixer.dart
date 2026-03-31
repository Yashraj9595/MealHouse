import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    var changed = false;

    // 1. Fix AppTheme imports
    final oldThemeImports = [
      'import \'../../theme/app_theme.dart\';',
      'import \'../../../theme/app_theme.dart\';',
      'import \'package:meal_house/shared/theme/app_theme.dart\';',
      'import \'package:meal_house/core/theme/app_theme.dart\';', // ensure consistent
    ];
    for (var imp in oldThemeImports) {
      if (content.contains(imp)) {
        content = content.replaceAll(imp, 'import \'package:meal_house/core/theme/app_theme.dart\';');
        changed = true;
      }
    }

    // 2. Fix ApiClient imports
    if (content.contains('package:meal_house/shared/api/api_client.dart')) {
      content = content.replaceAll(
        'package:meal_house/shared/api/api_client.dart',
        'package:meal_house/core/network/api_client.dart'
      );
      changed = true;
    }
    
    // 3. Fix AppConstants imports
    if (content.contains('import \'../constants/app_constants.dart\';')) {
      content = content.replaceAll(
        'import \'../constants/app_constants.dart\';',
        'import \'package:meal_house/core/constants/app_constants.dart\';'
      );
      changed = true;
    }

    // 4. Fix profile_screen to profile path references
    if (content.contains('package:meal_house/features/profile_screen/')) {
      content = content.replaceAll(
        'package:meal_house/features/profile_screen/',
        'package:meal_house/features/profile/'
      );
      changed = true;
    }

    // 5. Fix withOpacity deprecation
    if (content.contains('.withOpacity(')) {
      content = content.replaceAllMapped(
        RegExp(r'\.withOpacity\((0?\.\d+)\)'),
        (match) => '.withValues(alpha: ${match.group(1)})'
      );
      changed = true;
    }

    // 6. Fix invalid const with AppTheme
    if (content.contains('const ') && content.contains('AppTheme.')) {
      final lines = content.split('\n');
      var linesChanged = false;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('const ') && lines[i].contains('AppTheme.')) {
          lines[i] = lines[i].replaceFirst('const ', '');
          linesChanged = true;
        }
      }
      if (linesChanged) {
        content = lines.join('\n');
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed issues in ${file.path}');
    }
  }
  
  // 7. Fix StatusBadgeWidget in User feature specifically
  final userDir = Directory('lib/features/user');
  if (userDir.existsSync()) {
    final userFiles = userDir.listSync(recursive: true).whereType<File>();
    for (var file in userFiles) {
      var content = file.readAsStringSync();
      if (content.contains('StatusBadgeWidget(') && !content.contains('label:')) {
        content = content.replaceAll('StatusBadgeWidget(', 'StatusBadgeWidget(label: "STATUS", ');
        file.writeAsStringSync(content);
        print('Fixed StatusBadgeWidget in ${file.path}');
      }
    }
  }
}
