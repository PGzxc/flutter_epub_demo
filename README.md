# Flutter EPUB Reader Demo

一个基于Flutter的EPUB阅读器示例应用，支持EPUB文件加载、章节切换、样式设置等功能。

| ![][1] | ![][2] | ![][3] |
| ------ | ------ | ------ |
| ![][4] | ![][5] |        |

## 一 功能特性

### 1.1 核心功能
- ✅ EPUB文件加载与解压
- ✅ 自动扫描并生成章节列表
- ✅ 左右滑动切换章节
- ✅ 目录查看与章节跳转
- ✅ 样式设置（字体大小、背景色、文字颜色）
- ✅ 样式在页面切换时保持一致

### 1.2 技术特点
- 使用Flutter框架开发，支持跨平台
- 使用InAppWebView加载本地HTML文件
- 支持EPUB文件的自动解压和解析
- 响应式设计，适配不同屏幕尺寸
- 流畅的手势操作体验

## 二 项目结构

```
flutter_epub_demo/
├── lib/
│   ├── main.dart                 # 应用入口
│   └── reader/
│       ├── epub/
│       │   └── unzip/
│       │       └── unzip.dart    # EPUB文件解压逻辑
│       ├── reader_engine/
│       │   └── style_manager/
│       │       └── style_manager.dart  # 样式管理
│       └── ui/
│           ├── catalog_page/
│           │   └── catalog_page.dart   # 目录页面
│           ├── reader_page/
│           │   └── reader_page.dart    # 阅读器主页面
│           └── setting_page/
│               └── setting_page.dart   # 样式设置页面
├── pubspec.yaml                  # 项目依赖
└── README.md                     # 项目说明文档
```

## 三 快速上手

### 3.1 环境要求
- Flutter 3.0+
- Dart 2.17+
- Android SDK 21+ 或 iOS 11+

### 3.2 安装与运行

```
1、克隆项目
git clone https://github.com/yourusername/flutter_epub_demo.git
cd flutter_epub_demo

2、安装依赖
flutter pub get

3、运行项目
flutter run
```

### 3.3 使用指南

```
1. 加载EPUB文件
   - 点击应用首页的"加载EPUB"按钮
   - 选择本地的EPUB文件

2. 阅读操作
   - 左右滑动：切换章节
   - 顶部左侧菜单按钮：打开目录
   - 顶部右侧设置按钮：打开样式设置

3. 样式设置
   - 调整字体大小
   - 选择背景颜色
   - 选择文字颜色
   - 点击"应用"按钮保存设置

4. 目录操作
   - 点击目录项跳转到对应章节
   - 点击右上角关闭按钮关闭目录
```

## 四 技术实现细节

### 4.1 EPUB文件解压与解析

EPUB文件本质上是一个ZIP压缩包，包含HTML、CSS、图片等资源文件。应用使用`archive`库解压EPUB文件，并扫描其中的HTML文件作为章节列表。

```
关键代码：
// 解压EPUB文件
final archive = ZipDecoder().decodeBytes(epubBytes);
for (final file in archive) {
  final path = '${target.path}/${file.name}';
  if (file.name.endsWith('/')) {
    // 创建目录
    final dir = Directory(path);
    dir.createSync(recursive: true);
  } else {
    // 创建文件
    final out = File(path);
    out.createSync(recursive: true);
    out.writeAsBytesSync(file.content as List<int>);
  }
}
```

### 4.2 章节管理

应用会自动扫描解压后的EPUB文件，收集所有HTML文件作为章节列表，并在页面切换时保持样式一致。

```
关键代码：
// 加载章节列表
void _loadChapterList() {
  // 从当前章节路径中提取EPUB文件的根目录
  String epubRoot = widget.chapterPath.substring(0, widget.chapterPath.lastIndexOf('/'));
  // 向上一级，找到EPUB的根目录
  epubRoot = epubRoot.substring(0, epubRoot.lastIndexOf('/') + 1);
  
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
  }
}
```

### 4.3 手势操作与页面切换

使用Flutter的`GestureDetector`组件捕获左右滑动手势，实现章节切换功能。

```
关键代码：
// 手势检测
GestureDetector(
  onHorizontalDragEnd: (details) {
    if (details.primaryVelocity! > 0) {
      // 向右滑动，上一页
      _previousChapter();
    } else if (details.primaryVelocity! < 0) {
      // 向左滑动，下一页
      _nextChapter();
    }
  },
  child: InAppWebView(...),
)
```

### 4.4 样式设置

通过JavaScript注入修改HTML页面的样式，包括字体大小、背景色和文字颜色。

```
关键代码：
// 应用样式
void _applyStyleToCurrentPage() {
  controller.evaluateJavascript(source: """
    try {
      if (document.body) {
        document.body.style.fontSize='${_currentFontSize}px';
        document.body.style.backgroundColor='${_currentBgColor}';
        document.body.style.color='${_currentTextColor}';
        console.log('Style applied successfully');
      } else {
        console.log('Document body not found');
      }
    } catch (e) {
      console.error('Error applying style:', e);
    }
  """);
}
```

### 4.5 样式保持

在页面加载完成后自动应用保存的样式，确保样式在页面切换时保持一致。

```
关键代码：
// 页面加载完成后应用样式
InAppWebView(
  initialUrlRequest: URLRequest(url: WebUri(Uri.file(widget.chapterPath).toString())),
  onWebViewCreated: (c) => controller = c,
  onLoadStop: (controller, url) {
    // 页面加载完成后应用样式
    _applyStyleToCurrentPage();
  },
)
```

## 五 常见问题与解决方案

### 5.1 EPUB文件加载失败

**问题**：点击加载按钮后出现"Is a directory"错误。
**解决方案**：确保EPUB文件格式正确，应用会自动处理目录和文件的创建。

### 5.2 样式设置不生效

**问题**：设置字体大小和背景颜色后，切换页面样式不保持。
**解决方案**：应用已经实现了样式保持功能，会在页面加载完成后自动应用保存的样式。

### 5.3 目录不正确或跳转失败

**问题**：目录显示的是模拟数据，点击跳转后页面空白。
**解决方案**：应用会自动扫描EPUB文件中的HTML文件生成章节列表，并支持正确的章节跳转。

## 四 技术栈

- **Flutter**：跨平台UI框架
- **Dart**：编程语言
- **InAppWebView**：加载本地HTML文件
- **archive**：解压EPUB文件
- **path_provider**：获取本地存储路径

## 五 项目未来展望

- 支持更多EPUB格式特性（如CSS样式、多媒体内容）
- 添加阅读进度保存与恢复功能
- 实现夜间模式
- 支持字体选择
- 添加搜索功能
- 优化性能与用户体验


[1]:res/epub-flutter-1.png
[2]:res/epub-flutter-2.png
[3]:res/epub-flutter-3.png
[4]:res/epub-flutter-4.png
[5]:res/epub-flutter-5.png
[6]:res/epub-flutter-6.png



