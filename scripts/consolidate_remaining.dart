import 'dart:io';

void main() {
  final features = ['settings', 'wallet', 'profile_screen'];
  
  for (var feature in features) {
    final featureDir = Directory('lib/features/$feature');
    if (!featureDir.existsSync()) continue;

    final presentationDir = Directory('${featureDir.path}/presentation/screens');
    if (!presentationDir.existsSync()) {
      presentationDir.createSync(recursive: true);
    }

    final entities = featureDir.listSync();
    for (var entity in entities) {
      if (entity is Directory && !entity.path.contains('presentation') && !entity.path.contains('data') && !entity.path.contains('domain')) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        if (dirName.endsWith('_screen')) {
          final newPath = '${presentationDir.path}/$dirName';
          if (!Directory(newPath).existsSync()) {
            entity.renameSync(newPath);
            print('Moved ${entity.path} to $newPath');
          }
        }
      }
    }
  }
}
