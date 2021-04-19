import 'package:wallet/mvp/base/base.dart';

///
/// 资产 执行者
///

abstract class AssetPresenter implements IPresenter {
  void getAssetList(int page, int limit);
  void getBalance(String address);
  void getDelegationList(String delegatorAddress);
}

abstract class AssetView implements IView<AssetPresenter> {
  void onResponseAssetData(Map<String, dynamic> response);
  void onResponseBalanceData(Map<String, dynamic> response);
  void onResponseDelegationData(Map<String, dynamic> response);
}
