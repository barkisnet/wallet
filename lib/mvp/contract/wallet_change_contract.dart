import 'package:wallet/mvp/base/base.dart';

///
/// 切换钱包
///

abstract class WalletChangePresenter implements IPresenter {
  void getBalances(String address);
  void updateWalletData(String address);
}

abstract class WalletChangeView implements IView<WalletChangePresenter> {
  void onResponseBalanceData(Map<String, dynamic> response, String address);
  void onUpdateSuccess(int uid, String address);
}
