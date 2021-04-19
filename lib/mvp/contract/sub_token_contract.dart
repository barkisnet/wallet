import 'package:wallet/mvp/base/base.dart';

///
/// MainToken 执行者
///

abstract class SubTokenPresenter implements IPresenter {
  void getBalance(String address);
}

abstract class SubTokenView implements IView<SubTokenPresenter> {
  void onResponseBalanceData(Map<String, dynamic> response);
}
