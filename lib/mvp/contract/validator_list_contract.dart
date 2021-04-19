import 'package:wallet/mvp/base/base.dart';

///
/// 验证人列表 执行者
///

abstract class ValidatorListPresenter implements IPresenter {
  void getValidatorList(String status, int pageIndex, int limit);
}

abstract class ValidatorListView implements IView<ValidatorListPresenter> {
  void onResponseValidatorListData(Map<String, dynamic> response);
}
