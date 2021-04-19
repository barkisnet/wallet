import 'package:wallet/mvp/base/base.dart';

///
/// token发行列表 执行者
///

abstract class IssueListPresenter implements IPresenter {
  void getIssueList(int page, int limit);
}

abstract class IssueListView implements IView<IssueListPresenter> {
  void onResponseIssueListData(Map<String, dynamic> response);
}
