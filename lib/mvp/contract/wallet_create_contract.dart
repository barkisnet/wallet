import 'package:wallet/mvp/base/base.dart';

///
/// 钱包创建执行者
///

abstract class WalletCreatePresenter implements IPresenter {
  void createWalletData(Map<String, dynamic> params);
}

abstract class WalletCreateView implements IView<WalletCreatePresenter> {
  void onSuccess(Map<String, dynamic> response);
  void onFailure();
}