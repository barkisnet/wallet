import 'package:flutter/material.dart';

///
/// 交易详情 Model
///

class TxModel {
  String hash;
  String timeStamp;
  String fromAddress;
  String toAddress;
  String amount;
  String denom;

  TxModel();
}

class TxInfoModel {
  IconData icon;
  String name;
  String content;
  bool isCopy;
  bool isSuccess;

  TxInfoModel({this.icon, this.name, this.content, this.isCopy, this.isSuccess});
}