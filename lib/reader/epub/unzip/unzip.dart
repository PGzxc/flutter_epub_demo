import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> unzipEpub(File epub) async {
  final bytes = await epub.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  final dir = await getApplicationDocumentsDirectory();
  final target = Directory('${dir.path}/epub/book1');
  target.createSync(recursive: true);

  for (final file in archive) {
    final path = '${target.path}/${file.name}';
    if (file.name.endsWith('/')) {
      final dir = Directory(path);
      dir.createSync(recursive: true);
    } else {
      final out = File(path);
      out.createSync(recursive: true);
      out.writeAsBytesSync(file.content as List<int>);
    }
  }
  
  // 打印解压后的文件结构，方便调试
  print('解压完成，文件结构：');
  target.listSync(recursive: true).forEach((entity) {
    print('${entity.path}');
  });
  
  return target;
}
