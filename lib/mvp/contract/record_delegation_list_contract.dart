import 'package:wallet/mvp/base/base.dart';

///
/// 委托流水 执行者
///

abstract class RecordDelegationListPresenter implements IPresenter {
  void getParamsForDelegationList(String delegatorAddress);
  void getDelegationList(String delegatorAddress, int page, int limit);

  void getParamsForUndelegationList(String delegatorAddress);
  void getUndelegationList(String delegatorAddress, int page, int limit);

  void getParamsForRewardList(String delegatorAddress);
  void getRewardList(String delegatorAddress, int page, int limit);

  void getParamsForCommissionList(String valoperAddress);
  void getCommissionList(String valoperAddress, int page, int limit);

  void getValidator(String validatorAddress);
}

abstract class RecordDelegationListView implements IView<RecordDelegationListPresenter> {
  void onResponseParamsForListData(Map<String, dynamic> response);

  void onResponseDelegationListData(Map<String, dynamic> response);
  void onResponseUndelegationListData(Map<String, dynamic> response);
  void onResponseRewardListData(Map<String, dynamic> response);
  void onResponseCommissionListData(Map<String, dynamic> response);

  void onResponseValidatorData(Map<String, dynamic> response);
}
