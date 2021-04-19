import 'package:wallet/mvp/base/base.dart';

///
/// 资产 执行者
///

abstract class TxInfoPresenter implements IPresenter {
  void getTx(String hash);
}

abstract class TxInfoView implements IView<TxInfoPresenter> {
  void onResponseTxData(Map<String, dynamic> response);
}
