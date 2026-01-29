class StyleManager {
  int fontSize = 16;
  String backgroundColor = '#ffffff';
  String textColor = '#000000';

  void setFontSize(int size) {
    fontSize = size;
  }

  void setBackgroundColor(String color) {
    backgroundColor = color;
  }

  void setTextColor(String color) {
    textColor = color;
  }

  Map<String, dynamic> getCurrentStyle() {
    return {
      'fontSize': fontSize,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
    };
  }
}
