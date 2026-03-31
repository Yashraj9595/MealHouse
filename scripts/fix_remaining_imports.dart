import 'dart:io';

void main() {
  final features = ['settings', 'wallet', 'profile_screen'];
  
  for (var feature in features) {
    final dir = Directory('lib/features/$feature');
    if (!dir.existsSync()) continue;

    final files = dir.listSync(recursive: true).whereType<File>().toList();
    for (var file in files) {
      if (!file.path.endsWith('.dart')) continue;
      
      var content = file.readAsStringSync();
      var changed = false;

      // Fix relative imports of widgets and other screens
      // Since we moved from lib/features/F/S/S.dart to lib/features/F/presentation/screens/S/S.dart
      // Old: ../widgets/W.dart  -> lib/features/F/widgets/W.dart (but wait, were widgets also moved?)
      // Let's check where widgets are for these features.

      if (changed) {
        file.writeAsStringSync(content);
        print('Fixed imports in ${file.path}');
      }
    }
  }
}
