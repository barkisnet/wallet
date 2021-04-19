import 'package:wallet/mvp/base/base.dart';

///
/// 验证人详情 执行者
///

abstract class ValidatorDetailPresenter implements IPresenter {
  void getSelfDelegationRate(String delegatorAddress, String validatorAddress);
  void getDelegation(String delegatorAddress, String validatorAddress);
  void getRewardAndCommission(String validatorAddress);
  void getUndelegation(String delegatorAddress, String validatorAddress);
  void getReward(String delegatorAddress, String validatorAddress);
  void getBalance(String address);
}

abstract class ValidatorDetailView implements IView<ValidatorDetailPresenter> {
  void onResponseSelfDelegationRateData(Map<String, dynamic> response);
  void onResponseDelegationData(Map<String, dynamic> response);
  void onResponseRewardAndCommissionData(Map<String, dynamic> response);
  void onResponseUndelegationData(Map<String, dynamic> response);
  void onResponseRewardData(Map<String, dynamic> response);
  void onResponseBalanceData(Map<String, dynamic> response);
}
