import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallet/adapter/asset_detail_grid_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/asset_detail_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/main_token_contract.dart';
import 'package:wallet/mvp/presenter/main_token_presenter_impl.dart';
import 'package:wallet/mvp/view/qr/qr_code_page.dart';
import 'package:wallet/mvp/view/tx/tx_main_token_list_page.dart';
import 'package:wallet/mvp/view/tx/tx_send_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/string_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// MainToken资产页面
///

class AssetMainTokenPage extends StatefulWidget {
  WalletModel wallet;
  double availableAmount = 0;
  double delegationAmount = 0;

  AssetMainTokenPage(
      {this.wallet, this.availableAmount, this.delegationAmount});

  @override
  _AssetMainTokenPageState createState() => _AssetMainTokenPageState();
}

class _AssetMainTokenPageState extends State<AssetMainTokenPage>
    implements MainTokenView {
  List<AssetDetailModel> assetDetailList = List<AssetDetailModel>();

  MainTokenPresenter mPresenter;

  double rewardAmount = 0;
  double undelegationAmount = 0;

  Future scan() async {
//    var options = ScanOptions(
//      strings: {
//        "cancel": '取消',
//        "flash_on": '开灯',
//        "flash_off": '关灯',
//      },
//    );
    var result = await BarcodeScanner.scan();
    print('扫一扫结果：${result.rawContent}');
    navPush(
        context,
        TxSendPage(
            wallet: widget.wallet,
            denom: ChainParams.MAIN_TOKEN_DENOM,
            availableAmount: widget.availableAmount,
        recipientAddress: result.rawContent));
  }

  void _checkPersmissions() async {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    statusFuture.then((status) {
      if (status != PermissionStatus.granted) {
        requestPermission(PermissionGroup.camera);
      } else {
        scan();
      }
    });
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    log('permissionRequestResult = $permissionRequestResult');

    if (permissionRequestResult[permission] != PermissionStatus.granted) {
      ToastUtils.show(FlutterI18n.translate(context, "camera_permission"));
    } else {
      scan();
    }
  }

  Future<Null> _pullToRefresh() async {
    callData();
    return null;
  }

  void callData(){
    mPresenter.getRewardList(widget.wallet.address);
    mPresenter.getUndelegationList(widget.wallet.address);
  }

  @override
  void initState() {
    super.initState();

    mPresenter = MainTokenPresenterImpl(this);
    callData();

    assetDetailList.add(AssetDetailModel(
        icon: IconFont.ic_asset_available,
        name: 'delegation.available',
        amount: formatNum(widget.availableAmount, 4),
        iconColor: AppColors.CYAN));
    assetDetailList.add(AssetDetailModel(
        icon: IconFont.ic_asset_delegate,
        name: 'delegation.delegating',
        amount: formatNum(widget.delegationAmount, 4),
        iconColor: AppColors.PURPLE));
    assetDetailList.add(AssetDetailModel(
        icon: IconFont.ic_asset_rewards,
        name: 'delegation.reward',
        amount: "0.0000",
        iconColor: AppColors.GREEN));
    assetDetailList.add(AssetDetailModel(
        icon: IconFont.ic_asset_undelegation,
        name: 'delegation.undelegating',
        amount: "0.0000",
        iconColor: AppColors.BLUE));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          '${ChainParams.MAIN_TOKEN_SHORT_NAME} ${FlutterI18n.translate(context, "asset.title")}',
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(AppColors.MAIN_COLOR),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            icon: Icon(
              IconFont.ic_backarrow,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              navPop(context);
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_trade_record,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              navPush(
                  context,
                  MainTokenTxListPage(
                    wallet: widget.wallet,
                  ));
            },
          ),
        ],
      ),
      backgroundColor: Color(AppColors.MAIN_COLOR),
      body: RefreshIndicator(
        onRefresh: _pullToRefresh,
        child: Container(
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildCardView(context),
              _buildGridView(context),
              _buildAssetTitleDetailView(context),
              _buildGridDetailView(context),
            ],
          ),
        ),
      ),
//      endDrawer: WalletChangeDrawer(),
    );
  }

  Widget _buildCardView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      height: 205.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/card_bg_2.png',
            width: SystemUtils.getWidth(context) - 20.0,
            height: 190.0,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FixedSizeText(
                  widget.wallet.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: (){
                    navPush(context, QRCodePage(walletAddress: widget.wallet.address));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FixedSizeText(
                          formatShortAddress(widget.wallet.address, 10, 10),
                          style: TextStyle(
                            color: Color(AppColors.WHITE_70),
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Icon(
                          IconFont.ic_qr_code,
                          color: Color(AppColors.WHITE_70),
                          size: 18.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FixedSizeText(
                      formatNum(
                          widget.availableAmount +
                              widget.delegationAmount +
                              rewardAmount +
                              undelegationAmount,
                          6),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(
                      width: 3.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: FixedSizeText(
                        ChainParams.MAIN_TOKEN_SHORT_NAME,
                        style: TextStyle(
                          color: Color(AppColors.WHITE_70),
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0.0,
            child: Image.asset(
              'assets/images/card_shadow.png',
              width: SystemUtils.getWidth(context) - 40.0,
              height: 30.0,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                navPush(
                    context, QRCodePage(walletAddress: widget.wallet.address));
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_recipient,
                      size: 30,
                      color: Color(AppColors.COLOR_PRIMARY),
                    ),
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "tx.receive"),
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                navPush(
                    context,
                    TxSendPage(
                        wallet: widget.wallet,
                        denom: ChainParams.MAIN_TOKEN_DENOM,
                        availableAmount: widget.availableAmount));
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_wallet_2,
                      size: 30,
                      color: Color(AppColors.COLOR_PRIMARY),
                    ),
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "tx.transfer"),
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                navPop(context);
                eventBus.fire(ChangeMainPage());
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_delegate_2,
                      size: 30,
                      color: Color(AppColors.COLOR_PRIMARY),
                    ),
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "delegation.delegate"),
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                _checkPersmissions();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_scan,
                      size: 30,
                      color: Color(AppColors.COLOR_PRIMARY),
                    ),
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "button.scan"),
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTitleDetailView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
      child: FixedSizeText(
        FlutterI18n.translate(context, 'asset.detail'),
        style: TextStyle(
            color: Color(AppColors.BLACK),
            fontSize: 18.0,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGridDetailView(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        //GridView内边距
        padding: EdgeInsets.all(6.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //一行的Widget数量
          crossAxisCount: 2,
          //垂直子Widget之间间距
          mainAxisSpacing: 1.0,
          //水平子Widget之间间距
          crossAxisSpacing: 1.0,
          //子Widget宽高比例
          childAspectRatio: 1.5,
        ),
        itemCount: assetDetailList.length,
        itemBuilder: (context, index) {
          return AssetDetailGridItem(model: assetDetailList[index]);
        });
  }

  @override
  void dismissLoading() {
    // TODO: implement dismissLoading
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
  void onResponseBalanceData(Map<String, dynamic> response) {
    log('Main token Balance.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        if (f['denom'] == ChainParams.MAIN_TOKEN_DENOM) {
          setState(() {
            widget.availableAmount =
                double.parse(f['amount']) / ChainParams.MAIN_TOKEN_UNIT;
            assetDetailList[0].amount = formatNum(widget.availableAmount, 4);
          });
        }
      });
    }
  }

  @override
  void onResponseDelegationData(Map<String, dynamic> response) {
    log('Main Token Delegation.Resp = $response');

    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      double amount = 0;
      result.forEach((f) {
        amount += double.parse(f['balance']);
      });

      if (amount > 0) {
        setState(() {
          widget.delegationAmount = amount / ChainParams.MAIN_TOKEN_UNIT;
          assetDetailList[1].amount = formatNum(widget.delegationAmount, 4);
        });
      }
    }
  }

  @override
  void onResponseUndelegationData(Map<String, dynamic> response) {
    log('Undelegation.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      double amount = 0;
      result.forEach((f) {
        var entries = f['entries'];
        entries.forEach((e) {
          amount += double.parse(e['balance']);
        });
      });

      if (amount > 0) {
        setState(() {
          undelegationAmount = amount / ChainParams.MAIN_TOKEN_UNIT;
          assetDetailList[3].amount = formatNum(undelegationAmount, 4);
        });
      }
    }
  }

  @override
  void onResponseRewardData(Map<String, dynamic> response) {
    log('Reward.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      setState(() {
        rewardAmount =
            double.parse(result['total'][0]['amount']) / ChainParams.MAIN_TOKEN_UNIT;
        assetDetailList[2].amount = formatNum(rewardAmount, 4);
      });
    }
  }
}
