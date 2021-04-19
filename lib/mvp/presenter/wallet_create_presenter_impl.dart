import 'package:wallet/db/db_helper.dart';
import 'package:wallet/mvp/base/base.dart';
import 'package:wallet/mvp/contract/wallet_create_contract.dart';
import 'package:wallet/utils/log_utils.dart';

///
/// 执行者实现类
///

class WalletCreatePresenterImpl extends BasePresenter<WalletCreateView>
    implements WalletCreatePresenter {
  WalletCreatePresenterImpl(WalletCreateView view) : super(view);

  @override
  void createWalletData(Map<String, dynamic> params) {
    mView.showLoading();
    DbHelper.instance.insertWallet(params).then((value){
      mView.dismissLoading();
      if(value['id'] > 0){
        DbHelper.instance.updateSelectedWallet(params['address']).then((id){
          log('WalletCreatePresenterImpl.update.id = $id');
          mView.onSuccess(value);
        });
      } else {
        mView.onFailure();
      }
    });

  }
}
