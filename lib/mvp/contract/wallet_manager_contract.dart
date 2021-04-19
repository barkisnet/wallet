import 'package:wallet/mvp/base/base.dart';

///
/// 钱包管理
///

abstract class WalletManagerPresenter implements IPresenter {
  void getBalances(String address);
}

abstract class WalletManagerView implements IView<WalletManagerPresenter> {
  void onResponseBalanceData(Map<String, dynamic> response, String address);
}