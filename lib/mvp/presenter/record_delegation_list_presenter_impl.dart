import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/record_delegation_list_contract.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/mvp/repository/transaction_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 委托流水 执行者实现类
///

class RecordDelegationListPresenterImpl extends BasePresenter<RecordDelegationListView>
    implements RecordDelegationListPresenter {
  RecordDelegationListPresenterImpl(RecordDelegationListView view) : super(view);

  TransactionRepository _transactionRepository = TransactionRepository();
  StakingRepository _stakingRepository = StakingRepository();

  @override
  void getParamsForDelegationList(String delegatorAddress) {
    _transactionRepository.getDelegationList("delegate", delegatorAddress, 1, 1,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseParamsForListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getDelegationList(String delegatorAddress, int page, int limit) {
    _transactionRepository.getDelegationList("delegate", delegatorAddress, page, limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseDelegationListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getParamsForUndelegationList(String delegatorAddress) {
    _transactionRepository.getDelegationList("begin_unbonding", delegatorAddress, 1, 1,
    new ApiStateHook()
        .onStart(() => mView.showLoading())
        .onSuccess((Map<String, dynamic> response) {
          mView.onResponseParamsForListData(response);
        })
        .onError((msg) => mView.showMessage(msg))
        .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getUndelegationList(String delegatorAddress, int page, int limit) {
    _transactionRepository.getDelegationList("begin_unbonding", delegatorAddress, page, limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseUndelegationListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getParamsForRewardList(String delegatorAddress) {
    _transactionRepository.getDelegationList("withdraw_delegator_reward", delegatorAddress, 1, 1,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseParamsForListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getRewardList(String delegatorAddress, int page, int limit) {
    _transactionRepository.getDelegationList("withdraw_delegator_reward", delegatorAddress, page, limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseRewardListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getParamsForCommissionList(String valoperAddress) {
    _transactionRepository.getDelegationList("withdraw_validator_commission", valoperAddress, 1, 1,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseParamsForListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getCommissionList(String valoperAddress, int page, int limit) {
    _transactionRepository.getDelegationList("withdraw_validator_commission", valoperAddress, page, limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseCommissionListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getValidator(String validatorAddress) {
    _stakingRepository.getValidator(
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseValidatorData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
