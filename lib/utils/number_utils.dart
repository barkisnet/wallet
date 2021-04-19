
import 'package:wallet/utils/log_utils.dart';

String formatNum(double num, int postion) {
  var numStr = num.toStringAsFixed(20);
  log("format num=" + numStr);
  if (postion == 0) {
    return numStr
        .substring(0, numStr.lastIndexOf(".") + postion)
        .toString();
  }

  var newNumStr;
  if ((numStr.length - numStr.lastIndexOf(".") - 1) < postion) {
    newNumStr = num.toStringAsFixed(postion);
  } else {
    newNumStr = numStr;
  }

  var dotIndex = newNumStr.lastIndexOf(".");
  var newIntPart = formatIntNumStr(newNumStr.substring(0, dotIndex));

  return newIntPart +
      "." +
      newNumStr.substring(dotIndex + 1, dotIndex + 1 + postion);
}

String formatIntNumStr(String intNumStr) {
  return intNumStr.replaceAllMapped(
      new RegExp(r"(\d)(?=(?:\d{3})+\b)"), (match) => "${match.group(1)},");
}
