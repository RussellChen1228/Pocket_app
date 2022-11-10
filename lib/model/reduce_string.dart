class Reduce {
  static bool _isChinese(String s) {
    const String chineseUnicode = "[\u4e00-\u9fa5]";
    if (s.isEmpty) return false;
    return RegExp(chineseUnicode).hasMatch(s);
  }

  static String reduce(input, targetWidth) {
    String text = '';
    int width = 0;
    for (int i = 0; i < input.length; i++) {
      if (width >= targetWidth) {
        if (text[text.length - 1] != input[input.length - 1]) {
          return text + "...";
        } else {
          return text;
        }
      }
      if (_isChinese(input[i])) {
        width += 2;
        text += input[i];
      } else {
        width += 1;
        text += input[i];
      }
    }
    return input;
  }
}
