import 'dart:io';

Future<File> findFile(List<String> paths) async {
  for (final path in paths.where((path) => path != null && path.length > 0)) {
    final file = File(path);
    if (await file.exists() && await FileSystemEntity.isFile(path)) return file;
  }
  return null;
}