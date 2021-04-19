import 'package:wallet/mvp/base/base.dart';

///
/// MainToken 执行者
///

abstract class MainTokenPresenter implements IPresenter {
  void getBalance(String address);
  void getDelegationList(String delegatorAddress);
  void getUndelegationList(String delegatorAddress);
  void getRewardList(String delegatorAddress);
}

abstract class MainTokenView implements IView<MainTokenPresenter> {
  void onResponseBalanceData(Map<String, dynamic> response);
  void onResponseDelegationData(Map<String, dynamic> response);
  void onResponseUndelegationData(Map<String, dynamic> response);
  void onResponseRewardData(Map<String, dynamic> response);
}
