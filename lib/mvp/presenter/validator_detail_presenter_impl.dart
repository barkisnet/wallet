import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/validator_detail_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/mvp/repository/distribution_repository.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 验证人详情 执行者实现类
///

class ValidatorDetailPresenterImpl extends BasePresenter<ValidatorDetailView>
    implements ValidatorDetailPresenter {
  ValidatorDetailPresenterImpl(ValidatorDetailView view) : super(view);

  StakingRepository _stakingRepository = StakingRepository();
  DistributionRepository _distributionRepository = DistributionRepository();
  BankRepository _bankRepository = BankRepository();

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
  void getSelfDelegationRate(String delegatorAddress, String validatorAddress) {
    _stakingRepository.getDelegation(
        delegatorAddress,
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseSelfDelegationRateData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getDelegation(String delegatorAddress, String validatorAddress) {
    _stakingRepository.getDelegation(
        delegatorAddress,
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseDelegationData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getRewardAndCommission(String validatorAddress) {
    _distributionRepository.getRewardAndCommission(
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseRewardAndCommissionData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getUndelegation(String delegatorAddress, String validatorAddress) {
    _stakingRepository.getUndelegation(
        delegatorAddress,
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseUndelegationData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getReward(String delegatorAddress, String validatorAddress) {
    _distributionRepository.getReward(
        delegatorAddress,
        validatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseRewardData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
