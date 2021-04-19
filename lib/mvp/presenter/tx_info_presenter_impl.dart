import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/tx_info_contract.dart';
import 'package:wallet/mvp/repository/transaction_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// 资产 执行者实现类
///

class TxInfoPresenterImpl extends BasePresenter<TxInfoView>
    implements TxInfoPresenter {
  TxInfoPresenterImpl(TxInfoView view) : super(view);

  TransactionRepository _transactionRepository = TransactionRepository();

  @override
  void getTx(String hash) {
    _transactionRepository.getTx(
        hash,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseTxData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
