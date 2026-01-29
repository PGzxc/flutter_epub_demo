import 'package:flutter/material.dart';
import '../../reader_engine/style_manager/style_manager.dart';

class SettingPage extends StatefulWidget {
  final StyleManager styleManager;
  final Function(int, String, String) onApplyStyle;
  final Function() onClose;
  const SettingPage({required this.styleManager, required this.onApplyStyle, required this.onClose, super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late int _fontSize;
  late String _backgroundColor;
  late String _textColor;

  @override
  void initState() {
    super.initState();
    final currentStyle = widget.styleManager.getCurrentStyle();
    _fontSize = currentStyle['fontSize'];
    _backgroundColor = currentStyle['backgroundColor'];
    _textColor = currentStyle['textColor'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('字体大小', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _fontSize.toDouble(),
                    min: 12,
                    max: 24,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value.toInt();
                      });
                    },
                    onChangeEnd: (value) {
                      widget.styleManager.setFontSize(value.toInt());
                      widget.onApplyStyle(_fontSize, _backgroundColor, _textColor);
                    },
                  ),
                  SizedBox(height: 20),
                  Text('背景颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      colorOption('#ffffff'),
                      colorOption('#f5f5dc'),
                      colorOption('#e6e6fa'),
                      colorOption('#000000'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('文字颜色', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      colorOption('#000000', isTextColor: true),
                      colorOption('#333333', isTextColor: true),
                      colorOption('#ffffff', isTextColor: true),
                      colorOption('#ff0000', isTextColor: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget colorOption(String color, {bool isTextColor = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isTextColor) {
            _textColor = color;
            widget.styleManager.setTextColor(color);
          } else {
            _backgroundColor = color;
            widget.styleManager.setBackgroundColor(color);
          }
        });
        widget.onApplyStyle(_fontSize, _backgroundColor, _textColor);
      },
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceAll('#', '0xff'))),
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
