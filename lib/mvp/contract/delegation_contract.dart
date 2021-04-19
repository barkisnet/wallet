import 'package:wallet/mvp/base/base.dart';

///
/// 我的委托 执行者
///

abstract class DelegationPresenter implements IPresenter {
  void getDelegationList(String delegatorAddress);
  void getReward(String delegatorAddress);
  void getBalance(String address);
  void getUndelegationList(String delegatorAddress);
  void getValidator(String valoperAddress);
}

abstract class DelegationView implements IView<DelegationPresenter> {
  void onResponseDelegationListData(Map<String, dynamic> response);
  void onResponseRewardData(Map<String, dynamic> response);
  void onResponseBalanceData(Map<String, dynamic> response);
  void onResponseUndelegationListData(Map<String, dynamic> response);
  void onResponseValidatorData(Map<String, dynamic> response);
}
