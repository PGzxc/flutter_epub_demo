import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'reader/epub/unzip/unzip.dart';
import 'reader/ui/reader_page/reader_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EPUB Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  Future<void> _loadEpub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 请求存储权限
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('需要存储权限才能加载EPUB文件')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // 使用文件选择器让用户选择EPUB文件
      final typeGroup = XTypeGroup(
        label: 'epub',
        extensions: ['epub'],
      );

      final file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );

      if (file != null) {
        final epubFile = File(file.path);
        final unzipDir = await unzipEpub(epubFile);
        
        // 查找EPUB文件中的第一个HTML文件
        String? chapterPath;
        final files = unzipDir.listSync(recursive: true);
        for (final entity in files) {
          if (entity is File && (entity.path.endsWith('.html') || entity.path.endsWith('.htm'))) {
            chapterPath = entity.path;
            print('找到HTML文件: $chapterPath');
            break;
          }
        }

        if (chapterPath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReaderPage(chapterPath!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('EPUB文件中未找到HTML章节')),
          );
        }
      } else {
        // 用户取消了文件选择
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('文件选择已取消')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载EPUB文件失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter EPUB Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'EPUB 阅读器',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('点击下方按钮加载EPUB文件'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadEpub,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('加载EPUB'),
            ),
          ],
        ),
      ),
    );
  }
}
