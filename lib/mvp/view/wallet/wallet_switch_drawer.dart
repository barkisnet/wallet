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
import 'package:wallet/mvp/view/wallet/wallet_create_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_import_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 切换钱包的窗口从屏幕右边弹出
///

class WalletSwitchDrawer extends StatefulWidget {
  @override
  _WalletSwitchDrawerState createState() => _WalletSwitchDrawerState();
}

class _WalletSwitchDrawerState extends State<WalletSwitchDrawer>
    implements WalletChangeView {
  WalletChangePresenterImpl mPresenter;

  ScrollController _scrollController = ScrollController();

  List<WalletModel> walletList = List<WalletModel>();

  @override
  void initState() {
    super.initState();
    mPresenter = WalletChangePresenterImpl(this);

    DbHelper.instance.queryWalletList().then((list) {
      list.forEach((element) {
        log('change.wallet = $element');
        walletList.add(WalletModel(
            name: element['name'],
            address: element['address'],
            password: element['password'],
            mnemonic: element['mnemonic'],
            selected: element['selected'] > 0));
      });
      setState(() {});
      walletList.forEach((wallet) {
        mPresenter.getBalances(wallet.address);
      });
    });

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
    return Drawer(
      elevation: 1.0,
      child: Container(
        height: SystemUtils.getHeight(context),
        color: Color(AppColors.WHITE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 56.0, bottom: 10.0),
              child: FixedSizeText(
                FlutterI18n.translate(context, "wallet.switch"),
                style: TextStyle(
                    color: Color(AppColors.BLACK),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Divider(height: 1.0, color: Color(AppColors.SP_LINE_2)),
            Expanded(child: _buildWalletListView(context)),
            _buildCreateOrImportView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletListView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: walletList.length,
      padding: EdgeInsets.only(top: 5.0),
      itemBuilder: (context, index) {
        return WalletSwitchItem(wallet: walletList[index]);
      },
    );
  }

  Container _buildCreateOrImportView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context) - 56,
      padding: EdgeInsets.only(top: 10.0, bottom: 36.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                InkWell(
                  onTap: () {
                    navPush(context, WalletCreatePage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_creat_pocket,
                      size: 64,
                      color: Color(AppColors.GREEN),
                    ),
                  ),
                ),
                FixedSizeText(
                  FlutterI18n.translate(context, "wallet.create"),
                  style: TextStyle(
                      color: Color(AppColors.GREY_1),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    navPush(context, WalletImportPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_import_pocket,
                      size: 64,
                      color: Color(AppColors.BLUE),
                    ),
                  ),
                ),
                FixedSizeText(
                  FlutterI18n.translate(context, "wallet.import"),
                  style: TextStyle(
                      color: Color(AppColors.GREY_1),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dismissLoading() {
    // TODO: implement dismissLoading
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
    if(mounted) {
      setState(() {});
    }
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void showMessage(String msg) {
    // TODO: implement showMessage
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
    if(mounted) {
      setState(() {});
    }
  }
}
