import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/wallet_manager_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 钱包管理实现类
///

class WalletManagerPresenterImpl extends BasePresenter<WalletManagerView>
    implements WalletManagerPresenter {
  WalletManagerPresenterImpl(WalletManagerView view) : super(view);

  BankRepository _bankRepository = BankRepository();

  @override
  void getBalances(String address) {
    _bankRepository.getBalance(
        address,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseBalanceData(response, address);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
