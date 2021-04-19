///
/// 资产交易
///

class AssetTxModel {
  String hash;
  String address;
  DateTime datetime;
  String amount;
  bool isOut;

  AssetTxModel({this.hash, this.address, this.datetime, this.amount, this.isOut});
}
