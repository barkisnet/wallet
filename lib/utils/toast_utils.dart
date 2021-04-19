import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///
/// 弹出提示框的工具类
///

class ToastUtils {
  static void show(String message){
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Color(0x808c8c8c),
      textColor: Color(0xff333333),
      fontSize: 16.0,
    );
  }
}