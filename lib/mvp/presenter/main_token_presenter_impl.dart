import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/main_token_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/mvp/repository/distribution_repository.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// MainToken的执行者实现类
///

class MainTokenPresenterImpl extends BasePresenter<MainTokenView>
    implements MainTokenPresenter {
  MainTokenPresenterImpl(MainTokenView view) : super(view);

  BankRepository _bankRepository = BankRepository();
  DistributionRepository _distributionRepository = DistributionRepository();
  StakingRepository _stakingRepository = StakingRepository();

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
  void getDelegationList(String delegatorAddress) {
    _stakingRepository.getDelegationList(
        delegatorAddress,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseDelegationData(response);
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
          mView.onResponseUndelegationData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getRewardList(String delegatorAddress) {
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
}
