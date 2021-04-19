import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/wallet_switch_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/wallet_change_contract.dart';
import 'package:wallet/mvp/presenter/wallet_change_presenter_impl.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 切换钱包的窗口从屏幕下方弹出
///

class WalletSwitchBottomSheet extends StatefulWidget {
  @override
  _WalletSwitchBottomSheetState createState() =>
      _WalletSwitchBottomSheetState();
}

class _WalletSwitchBottomSheetState
    extends State<WalletSwitchBottomSheet> implements WalletChangeView {
  WalletChangePresenterImpl mPresenter;

  ScrollController _scrollController = ScrollController();

  List<WalletModel> walletList = List<WalletModel>();

  void initDbWalletList() {
    DbHelper.instance.queryWalletList().then((list) {
      if (walletList.isNotEmpty) {
        walletList.clear();
      }
      list.forEach((element) {
        log('change.wallet = $element');
        walletList.add(WalletModel(
            name: element['name'],
            address: element['address'],
            password: element['password'],
            mnemonic: element['mnemonic'],
            createTime: element['createTime'],
            selected: element['selected'] > 0));
      });
      if (mounted) {
        setState(() {});
      }
      walletList.forEach((wallet) {
        mPresenter.getBalances(wallet.address);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    mPresenter = WalletChangePresenterImpl(this);
    initDbWalletList();

    eventBus.on<WalletChangeListener>().listen((event) {
      mPresenter.updateWalletData(event.address);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          child: _buildWalletListView(context),
        ),
      ],
    );
  }

  Widget _buildWalletListView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      height: SystemUtils.getHeight(context) / 2 + 50,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Color(AppColors.WHITE),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: FixedSizeText(
                      FlutterI18n.translate(context, "wallet.switch"),
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none)),
                ),
                Material(
                  color: Color(AppColors.WHITE),
                  child: InkWell(
                    onTap: (){
                      navPush(context, WalletManagerPage());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            IconFont.ic_tab_setting_2,
                            color: Color(AppColors.COLOR_PRIMARY),
                            size: 14.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 8.0),
                            child: FixedSizeText(
                                FlutterI18n.translate(context, "wallet.title"),
                                style: TextStyle(
                                    color: Color(AppColors.COLOR_PRIMARY),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 2.0),
            child: Divider(height: 1.0, color: Color(AppColors.SP_LINE_2),),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: walletList.length,
              itemBuilder: (context, index) {
                return WalletSwitchItem(wallet: walletList[index]);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void onResponseBalanceData(Map<String, dynamic> response, String address) {
    log('Balance.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        if (ChainParams.MAIN_TOKEN_DENOM == f['denom']) {
          walletList.forEach((wallet) {
            if (wallet.address == address) {
              wallet.balance = double.parse(f['amount']);
            }
          });
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void onUpdateSuccess(int uid, String address) {
    walletList.forEach((wallet) {
      if (wallet.address == address) {
        wallet.selected = true;
        SPUtils.setWalletModel(wallet).then((value) {
          eventBus.fire(WalletChangeSuccess(model: wallet));
          Navigator.pop(context);
        });
      } else {
        wallet.selected = false;
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void dismissLoading() {
    // TODO: implement dismissLoading
  }

  @override
  void showMessage(String msg) {
    // TODO: implement showMessage
  }
}
