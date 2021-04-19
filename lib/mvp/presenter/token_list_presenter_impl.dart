import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/token_list_contract.dart';
import 'package:wallet/mvp/repository/transaction_repository.dart';
import 'package:wallet/net/api_service.dart';

///
/// Token流水的执行者实现类
///
class TokenListPresenterImpl extends BasePresenter<TokenListView>
    implements TokenListPresenter {
  TokenListPresenterImpl(TokenListView view) : super(view);

  TransactionRepository _transactionRepository = TransactionRepository();

  @override
  void getParamsForOutTxList(String address) {
    _transactionRepository.getOutTxList(
        address,
        1,
        1,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseParamsForTxData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getOutTxList(String address, int page, int limit) {
    _transactionRepository.getOutTxList(
        address,
        page,
        limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseTxData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getParamsForInTxList(String address) {
    _transactionRepository.getInTxList(
        address,
        1,
        1,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseParamsForTxData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }

  @override
  void getInTxList(String address, int page, int limit) {
    _transactionRepository.getInTxList(
        address,
        page,
        limit,
        new ApiStateHook()
            .onStart(() => mView.showLoading())
            .onSuccess((Map<String, dynamic> response) {
              mView.onResponseTxData(response);
            })
            .onError((msg) => mView.showMessage(msg))
            .onFinally(() => mView.dismissLoading()));
  }
}
