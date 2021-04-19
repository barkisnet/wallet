import 'package:wallet/mvp/base/base.dart';

///
/// Token交易流水 执行者
///

abstract class TokenListPresenter implements IPresenter {
  void getParamsForOutTxList(String walletAddress);
  void getOutTxList(String walletAddress, int page, int limit);

  void getParamsForInTxList(String walletAddress);
  void getInTxList(String walletAddress, int page, int limit);
}

abstract class TokenListView implements IView<TokenListPresenter> {
  void onResponseParamsForTxData(Map<String, dynamic> response);
  void onResponseTxData(Map<String, dynamic> response);
}
