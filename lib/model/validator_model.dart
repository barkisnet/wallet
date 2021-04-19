///
/// 验证人详情
///

class ValidatorModel {
  String validatorName;
  String bech32Address;
  String valoperAddress;
  double delegationAmount = 0;
  double undelegationAmount = 0;
  double rewardAmount = 0;
  double commissionAmount = 0;
  double commissionRate = 0;
  double selfDelegationRate = 0;

  // 以下两个参数是从lcd的验证人接口取出来，用来计算准确的委托数据的
  // 由于被slash过验证人，会存在shares与balance的区别，所以需要获取验证人详情，计算准确的委托数据
  // 计算公式=(验证人的tokens/验证人的delegator_shares)*委托人的shares
  double tokens = 0;
  double delegatorShares = 0;

  bool jailed = false;

  ValidatorModel(
      {this.validatorName,
      this.bech32Address,
      this.valoperAddress,
      this.delegationAmount,
      this.undelegationAmount,
      this.rewardAmount,
      this.commissionRate,
      this.tokens,
      this.delegatorShares,
      this.jailed=false});
}
