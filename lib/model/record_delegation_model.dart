///
/// 委托记录对象
///

class RecordDelegationModel {
  String type;
  String typeLabel;
  String validatorName;
  String shortValidatorAddress;
  String longValidatorAddress;
  String amount;

  //在委托与赎回时，会自动获取收益，rewardAmount字段就是用来接收这个收益的，在主动领取收益时，用amount字段
  String rewardAmount;
  DateTime datetime;
  bool successful;

  RecordDelegationModel(
      {this.type,
      this.typeLabel,
      this.validatorName,
      this.shortValidatorAddress,
      this.longValidatorAddress,
      this.amount,
      this.rewardAmount,
      this.datetime,
      this.successful});
}
