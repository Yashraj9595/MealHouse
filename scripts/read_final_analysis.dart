import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('analysis_final_check.txt');
  final bytes = await file.readAsBytes();
  // Try decoding as UTF-16LE, then UTF-8
  String content;
  try {
    content = utf16.decode(bytes);
  } catch (e) {
    content = utf8.decode(bytes, allowMalformed: true);
  }
  
  final lines = content.split('\n');
  print('Total issues: ${lines.length}');
  for (var i = 0; i < lines.length && i < 100; i++) {
    print(lines[i]);
  }
}
