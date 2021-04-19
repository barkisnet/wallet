import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/delegation_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/mvp/repository/distribution_repository.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 我的验证 执行者实现类
///

class DelegationPresenterImpl extends BasePresenter<DelegationView>
    implements DelegationPresenter {
  DelegationPresenterImpl(DelegationView view) : super(view);

  BankRepository _bankRepository = BankRepository();
  StakingRepository _stakingRepository = StakingRepository();
  DistributionRepository _distributionRepository = DistributionRepository();

  @override
  void getDelegationList(String delegatorAddress) {
    _stakingRepository.getDelegationList(
        delegatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseDelegationListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getReward(String delegatorAddress) {
    _distributionRepository.getRewardList(
        delegatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseRewardData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getBalance(String address) {
    _bankRepository.getBalance(
        address,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseBalanceData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getUndelegationList(String delegatorAddress) {
    _stakingRepository.getUndelegationList(
        delegatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseUndelegationListData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getValidator(String valoperAddress) {
    _stakingRepository.getValidator(
        valoperAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseValidatorData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
