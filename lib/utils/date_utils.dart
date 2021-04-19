import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

///
/// 日期相关的工具类
///

var format = formatDate(DateTime.now(), [yyyy, '.', mm, '.', dd]);

///
/// 解析从链上获取的时间（0时区），需要改为东8区
///
DateTime parseDatetimeFromChain(String dateTime0UTC) {
  var dt = DateTime.parse(dateTime0UTC);
  return dt.add(Duration(hours: 8));
}

String formatDatetime(DateTime dateTime) {
  DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
  return format.format(dateTime);
}
