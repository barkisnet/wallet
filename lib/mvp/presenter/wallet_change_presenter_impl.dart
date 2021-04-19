import 'package:wallet/db/db_helper.dart';
import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/wallet_change_contract.dart';
import 'package:wallet/mvp/repository/bank_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 钱包切换实现类
///

class WalletChangePresenterImpl extends BasePresenter<WalletChangeView>
    implements WalletChangePresenter {
  WalletChangePresenterImpl(WalletChangeView view) : super(view);

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

  @override
  void updateWalletData(String address) {
    DbHelper.instance.updateSelectedWallet(address).then((uid) {
      mView.onUpdateSuccess(uid, address);
    });
  }
}
