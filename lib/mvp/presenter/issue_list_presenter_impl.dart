import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/asset_contract.dart';
import 'package:wallet/mvp/contract/issue_list_contract.dart';
import 'package:wallet/mvp/repository/asset_repository.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 资产 执行者实现类
///

class IssueListPresenterImpl extends BasePresenter<IssueListView>
    implements IssueListPresenter {
  IssueListPresenterImpl(IssueListView view) : super(view);

  AssetRepository _assetRepository = AssetRepository();

  @override
  void getIssueList(int page, int limit) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['page'] = page;
    params['limit'] = limit;
    _assetRepository.getAssetList(
        params,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseIssueListData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
