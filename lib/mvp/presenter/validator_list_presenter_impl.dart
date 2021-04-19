import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/validator_list_contract.dart';
import 'package:wallet/mvp/repository/staking_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 验证人列表 执行者实现类
///

class ValidatorListPresenterImpl extends BasePresenter<ValidatorListView>
    implements ValidatorListPresenter {
  ValidatorListPresenterImpl(ValidatorListView view) : super(view);

  StakingRepository _stakingRepository = StakingRepository();

  @override
  void getValidatorList(String status, int pageIndex, int limit) {
    _stakingRepository.getValidatorList(
        status,
        pageIndex,
        limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseValidatorListData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
