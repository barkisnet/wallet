import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/asset_contract.dart';
import 'package:wallet/mvp/repository/asset_repository.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 资产 执行者实现类
///

class AssetPresenterImpl extends BasePresenter<AssetView>
    implements AssetPresenter {
  AssetPresenterImpl(AssetView view) : super(view);

  AssetRepository _assetRepository = AssetRepository();
  BankRepository _bankRepository = BankRepository();
  StakingRepository _stakingRepository = StakingRepository();

  @override
  void getAssetList(int page, int limit) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['page'] = page;
    params['limit'] = limit;
    _assetRepository.getAssetList(
        params,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseAssetData(response);
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
}
