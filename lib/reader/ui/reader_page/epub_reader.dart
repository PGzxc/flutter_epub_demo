import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EpubReader extends StatefulWidget {
  final String chapterPath;
  const EpubReader(this.chapterPath, {super.key});

  @override
  State<EpubReader> createState() => _EpubReaderState();

  // 公开方法，允许外部访问
  void applyStyle(BuildContext context, int fontSize, String bg, String color) {
    final state = context.findAncestorStateOfType<_EpubReaderState>();
    if (state != null) {
      state._applyStyle(fontSize, bg, color);
    }
  }

  void jumpToChapter(BuildContext context, String path) {
    final state = context.findAncestorStateOfType<_EpubReaderState>();
    if (state != null) {
      state._jumpToChapter(path);
    }
  }
}

class _EpubReaderState extends State<EpubReader> {
  late InAppWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: widget.chapterPath,
      onWebViewCreated: (c) => controller = c,
    );
  }

  void _applyStyle(int fontSize, String bg, String color) {
    controller.evaluateJavascript(source: """
      document.body.style.fontSize='${fontSize}px';
      document.body.style.backgroundColor='$bg';
      document.body.style.color='$color';
    """);
  }

  void _jumpToChapter(String path) {
    controller.loadUrl(urlRequest: URLRequest(url: WebUri(Uri.file(path).toString())));
  }
}
