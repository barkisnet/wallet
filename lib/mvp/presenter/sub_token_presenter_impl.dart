import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/sub_token_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// MainToken的执行者实现类
///

class MainTokenPresenterImpl extends BasePresenter<SubTokenView>
    implements SubTokenPresenter {
  MainTokenPresenterImpl(SubTokenView view) : super(view);

  BankRepository _bankRepository = BankRepository();

  @override
  void getBalance(String address) {
    _bankRepository.getBalance(
        address,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
          mView.onResponseBalanceData(response);
        })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
