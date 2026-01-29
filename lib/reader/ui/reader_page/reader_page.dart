import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../catalog_page/catalog_page.dart';
import '../setting_page/setting_page.dart';
import '../../reader_engine/style_manager/style_manager.dart';

class ReaderPage extends StatefulWidget {
  final String chapterPath;
  const ReaderPage(this.chapterPath, {super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final StyleManager _styleManager = StyleManager();
  final GlobalKey<EpubReaderState> _epubReaderKey = GlobalKey();
  bool _showCatalog = false;
  bool _showSettings = false;
  List<Map<String, String>> _chapterCatalog = [];

  @override
  void initState() {
    super.initState();
    _loadChapterCatalog();
  }

  void _loadChapterCatalog() {
    // 从当前章节路径中提取EPUB文件的根目录
    String epubRoot = widget.chapterPath.substring(0, widget.chapterPath.lastIndexOf('/'));
    // 向上一级，找到EPUB的根目录
    epubRoot = epubRoot.substring(0, epubRoot.lastIndexOf('/') + 1);
    print('EPUB root directory for catalog: $epubRoot');
    
    // 扫描所有HTML文件作为章节列表
    final directory = Directory(epubRoot);
    if (directory.existsSync()) {
      final files = directory.listSync(recursive: true);
      int chapterIndex = 1;
      for (final file in files) {
        if (file is File && (file.path.endsWith('.html') || file.path.endsWith('.htm') || file.path.endsWith('.xhtml'))) {
          // 提取文件名作为章节标题
          String fileName = file.path.substring(file.path.lastIndexOf('/') + 1);
          String chapterTitle = '第${chapterIndex++}章: $fileName';
          _chapterCatalog.add({
            'title': chapterTitle,
            'path': file.path
          });
        }
      }
      print('Chapter catalog loaded: ${_chapterCatalog.length} chapters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          EpubReaderWithState(widget.chapterPath, key: _epubReaderKey),
          if (_showCatalog) CatalogPage(
            chapters: _chapterCatalog,
            onChapterSelected: (path) {
              print('Chapter selected: $path');
              if (_epubReaderKey.currentState != null) {
                _epubReaderKey.currentState?.jumpToChapter(path);
              } else {
                print('EpubReaderState is null');
              }
              setState(() {
                _showCatalog = false;
              });
            },
            onClose: () {
              setState(() {
                _showCatalog = false;
              });
            },
          ),
          if (_showSettings) SettingPage(
            styleManager: _styleManager,
            onApplyStyle: (fontSize, bg, color) {
              print('Applying style from ReaderPage: fontSize=$fontSize, bg=$bg, color=$color');
              if (_epubReaderKey.currentState != null) {
                _epubReaderKey.currentState?.applyStyle(fontSize, bg, color);
              } else {
                print('EpubReaderState is null');
              }
            },
            onClose: () {
              setState(() {
                _showSettings = false;
              });
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      print('Menu button pressed');
                      setState(() {
                        _showCatalog = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      print('Settings button pressed');
                      setState(() {
                        _showSettings = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 带状态的EpubReader包装类
class EpubReaderWithState extends StatefulWidget {
  final String chapterPath;
  const EpubReaderWithState(this.chapterPath, {Key? key}) : super(key: key);

  @override
  EpubReaderState createState() => EpubReaderState();
}

class EpubReaderState extends State<EpubReaderWithState> {
  late InAppWebViewController controller;
  List<String> _chapterList = [];
  int _currentChapterIndex = 0;
  int _currentFontSize = 16;
  String _currentBgColor = '#ffffff';
  String _currentTextColor = '#000000';

  @override
  void initState() {
    super.initState();
    _loadChapterList();
  }

  void _loadChapterList() {
    // 从当前章节路径中提取EPUB文件的根目录
    String epubRoot = widget.chapterPath.substring(0, widget.chapterPath.lastIndexOf('/'));
    // 向上一级，找到EPUB的根目录
    epubRoot = epubRoot.substring(0, epubRoot.lastIndexOf('/') + 1);
    print('EPUB root directory: $epubRoot');
    
    // 扫描所有HTML文件作为章节列表
    final directory = Directory(epubRoot);
    if (directory.existsSync()) {
      final files = directory.listSync(recursive: true);
      for (final file in files) {
        if (file is File && (file.path.endsWith('.html') || file.path.endsWith('.htm') || file.path.endsWith('.xhtml'))) {
          _chapterList.add(file.path);
        }
      }
      // 排序章节列表，确保顺序正确
      _chapterList.sort();
      // 找到当前章节在列表中的索引
      _currentChapterIndex = _chapterList.indexOf(widget.chapterPath);
      if (_currentChapterIndex == -1) {
        _currentChapterIndex = 0;
      }
      print('Chapter list loaded: ${_chapterList.length} chapters');
      print('Current chapter index: $_currentChapterIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building EpubReaderState with chapter path: ${widget.chapterPath}');
    print('File exists: ${File(widget.chapterPath).existsSync()}');
    print('File size: ${File(widget.chapterPath).lengthSync()} bytes');
    
    final fileUri = Uri.file(widget.chapterPath);
    print('File URI: $fileUri');
    
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // 向右滑动，上一页
          print('向右滑动，上一页');
          _previousChapter();
        } else if (details.primaryVelocity! < 0) {
          // 向左滑动，下一页
          print('向左滑动，下一页');
          _nextChapter();
        }
      },
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(fileUri.toString())),
        onWebViewCreated: (c) {
          print('WebView created');
          controller = c;
        },
        onLoadStart: (controller, url) {
          print('Loading started: $url');
        },
        onLoadStop: (controller, url) {
          print('Loading stopped: $url');
          // 页面加载完成后应用样式
          _applyStyleToCurrentPage();
        },
        onLoadError: (controller, url, code, message) {
          print('Loading error: $code - $message');
          print('URL: $url');
        },
        onConsoleMessage: (controller, consoleMessage) {
          print('Console message: ${consoleMessage.message}');
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          print('Permission request for: $resources from origin: $origin');
          return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT,
          );
        },
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          domStorageEnabled: true,
          allowContentAccess: true,
          allowFileAccess: true,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
      ),
    );
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _currentChapterIndex--;
      String previousChapter = _chapterList[_currentChapterIndex];
      print('Loading previous chapter: $previousChapter');
      controller.loadUrl(urlRequest: URLRequest(url: WebUri(Uri.file(previousChapter).toString())));
    } else {
      print('Already at the first chapter');
    }
  }

  void _nextChapter() {
    if (_currentChapterIndex < _chapterList.length - 1) {
      _currentChapterIndex++;
      String nextChapter = _chapterList[_currentChapterIndex];
      print('Loading next chapter: $nextChapter');
      controller.loadUrl(urlRequest: URLRequest(url: WebUri(Uri.file(nextChapter).toString())));
    } else {
      print('Already at the last chapter');
    }
  }

  void _applyStyleToCurrentPage() {
    print('Applying style to current page: fontSize=$_currentFontSize, bg=$_currentBgColor, color=$_currentTextColor');
    controller.evaluateJavascript(source: """
      try {
        if (document.body) {
          // 应用样式到body元素
          document.body.style.fontSize='${_currentFontSize}px';
          document.body.style.backgroundColor='${_currentBgColor}';
          document.body.style.color='${_currentTextColor}';
          
          // 应用样式到所有文本元素，确保覆盖EPUB自带的CSS
          var textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, span, div, li, a');
          for (var i = 0; i < textElements.length; i++) {
            textElements[i].style.fontSize = '${_currentFontSize}px';
            textElements[i].style.color = '${_currentTextColor}';
          }
          
          // 确保所有元素继承正确的颜色
          document.body.style.color = '${_currentTextColor}';
          document.body.style.webkitTextFillColor = '${_currentTextColor}';
          
          console.log('Style applied successfully to all elements');
          console.log('Body color:', document.body.style.color);
          console.log('First paragraph color:', document.querySelector('p') ? document.querySelector('p').style.color : 'No p elements');
        } else {
          console.log('Document body not found');
        }
      } catch (e) {
        console.error('Error applying style:', e);
      }
    """);
  }

  void applyStyle(int fontSize, String bg, String color) {
    print('Applying style: fontSize=$fontSize, bg=$bg, color=$color');
    // 保存当前样式
    _currentFontSize = fontSize;
    _currentBgColor = bg;
    _currentTextColor = color;
    // 应用样式到当前页面
    _applyStyleToCurrentPage();
  }

  void jumpToChapter(String path) {
    print('Jumping to chapter: $path');
    // 检查路径是否为相对路径，如果是则转换为绝对路径
    String absolutePath = path;
    if (!path.startsWith('/')) {
      // 从当前章节路径中提取EPUB文件的根目录
      String epubRoot = widget.chapterPath.substring(0, widget.chapterPath.lastIndexOf('/'));
      // 向上一级，找到EPUB的根目录
      epubRoot = epubRoot.substring(0, epubRoot.lastIndexOf('/') + 1);
      absolutePath = '$epubRoot$path';
    }
    print('Absolute chapter path: $absolutePath');
    controller.loadUrl(urlRequest: URLRequest(url: WebUri(Uri.file(absolutePath).toString())));
    // 更新当前章节索引
    _currentChapterIndex = _chapterList.indexOf(absolutePath);
    if (_currentChapterIndex == -1) {
      _currentChapterIndex = 0;
    }
  }
}
