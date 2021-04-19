import 'package:wallet/mvp/base/base.dart';

///
/// 钱包导入执行者
///

abstract class WalletImportPresenter implements IPresenter {
  void importWalletData(Map<String, dynamic> params);
}

abstract class WalletImportView implements IView<WalletImportPresenter> {
  void onSuccess(Map<String, dynamic> response);
  void onFailure();
}