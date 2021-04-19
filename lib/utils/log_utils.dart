import '../config.dart';

///
/// log 日志打印工具类
///

void log(String text) {
  if (!Config.debug) return;
  if (text == null) {
    print('');
  }
  int size = text.length;
  //  print('size = $size');
  double splitLenght = size / 500;
  //  print('splitLenght = $splitLenght');
  int sum = splitLenght.floor() + 1;
  //  print('sum = $sum');
  //  print('log.result = ');
  for (int i = 0; i < sum; i++) {
    if (i == sum - 1) {
      print(text.substring(i * 500, size));
    } else {
      print(text.substring(i * 500, (i + 1) * 500));
    }
  }
}
