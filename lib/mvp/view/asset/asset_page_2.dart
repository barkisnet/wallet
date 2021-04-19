import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wallet/adapter/asset_token_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/token_item_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/asset_contract.dart';
import 'package:wallet/mvp/presenter/asset_presenter_impl.dart';
import 'package:wallet/mvp/view/asset/asset_main_token_page.dart';
import 'package:wallet/mvp/view/qr/qr_code_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_switch_bottom_sheet.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/string_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 第2种风格的资产首页
///

class AssetPage2 extends StatefulWidget {
  @override
  _AssetPage2State createState() => _AssetPage2State();
}

class _AssetPage2State extends State<AssetPage2> with AutomaticKeepAliveClientMixin implements AssetView {
  AssetPresenterImpl mPresenter;

  WalletModel wallet = new WalletModel();
  TokenItemModel mainTokenModel = TokenItemModel();
  List<TokenItemModel> subTokenList = List<TokenItemModel>();

  List<String> EXCLUDE_SYMBOL = ["etoken", "app"];

  ScrollController _scrollController = ScrollController();
  ScrollController _subTokenScrollController = ScrollController();

  bool _saving = false;

  int page = 1;

  void initWalletInfo() {
    SPUtils.getWalletInfo().then((walletInfo) {
      setState(() {
        wallet = walletInfo;
      });
    });
  }

  Future<Null> _pullToRefresh() async {
    page = 1;
    mPresenter.getAssetList(page, 10);
    return null;
  }

  //AutomaticKeepAliveClientMixin 需添加
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //初始化获取当前钱包信息
    initWalletInfo();

    mPresenter = AssetPresenterImpl(this);

    log('mPresenter = $mPresenter');

    mPresenter.getAssetList(1, 100);

    eventBus.on<WalletChangeSuccess>().listen((event) {
      setState(() {
        _saving = true;
      });
      mPresenter.getAssetList(1, 100);
      setState(() {
        wallet = event.model;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _subTokenScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "app_name", translationParams: {"tokenName": ChainParams.MAIN_TOKEN_FULL_NAME}),
          style: TextStyle(
            color: Color(AppColors.WHITE),
            fontWeight: FontWeight.bold,
            fontSize: 16.0),
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Color(AppColors.COLOR_PRIMARY),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 14.0, bottom: 14.0),
            child: Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: InkWell(
                onTap: () {
                  showChangeWalletDialog(context);
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_white.png',
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: FixedSizeText(
                        FlutterI18n.translate(context, "wallet.switch"),
                        style: TextStyle(
                            color: Color(AppColors.WHITE),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0),
                      ),
                    ),
                    Icon(IconFont.ic_dropdownone,
                      color: Color(AppColors.WHITE),)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color(AppColors.WHITE),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        progressIndicator: Container(
          width: SystemUtils.getWidth(context),
          height: SystemUtils.getHeight(context) - 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoActivityIndicator(),
              SizedBox(
                height: 8.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "loading"),
                style: TextStyle(
                    color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        child: Container(
          child: Column(
            children: [
              _buildCardView(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _pullToRefresh,
                  child: Container(
                    height: SystemUtils.getHeight(context) - 220,
                    child: ListView(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      children: [
                        _buildMainTokenView(context),
                        _buildSubTokenView(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      height: 220.0,
      child: Stack(
        children: [
          Container(
            height: 130.0,
            decoration: BoxDecoration(
              color: Color(AppColors.COLOR_PRIMARY),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
            child: Image.asset(
              'assets/images/card_bg.png',
              width: SystemUtils.getWidth(context) - 20.0,
              height: 190.0,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 10.0, bottom: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FixedSizeText(
                      wallet.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    navPush(context, QRCodePage(walletAddress: wallet.address));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, right: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FixedSizeText(
                          formatShortAddress(wallet.address, 10, 10),
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
                          mainTokenModel.amount +
                              mainTokenModel.delegationAmount,
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
                          fontSize: 12.0,
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
              width: SystemUtils.getWidth(context) - 30.0,
              height: 60.0,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTokenView(BuildContext context) {
    return InkWell(
      onTap: () {
        navPush(
            context,
            AssetMainTokenPage(
              wallet: wallet,
              availableAmount: mainTokenModel.amount,
              delegationAmount: mainTokenModel.delegationAmount,
            ));
      },
      child: Container(
        child: Card(
          elevation: 0.0,
          color: Color(AppColors.MAIN_COLOR),
          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          //设置圆角
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 12.0, top: 16.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FixedSizeText(
                        ChainParams.MAIN_TOKEN_SHORT_NAME,
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      IconFont.ic_arrowone,
                      color: Color(AppColors.GREY_1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 12.0, bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: (SystemUtils.getWidth(context) - 52) / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FixedSizeText(
                            FlutterI18n.translate(context, 'delegation.available'),
                            style: TextStyle(
                                color: Color(AppColors.GREY_1), fontSize: 12.0),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          FixedSizeText(
                            formatNum(mainTokenModel.amount, 4),
                            style: TextStyle(
                                color: Color(AppColors.BLACK),
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FixedSizeText(
                          FlutterI18n.translate(context, 'delegation.delegated'),
                          style: TextStyle(
                              color: Color(AppColors.GREY_1), fontSize: 12.0),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        FixedSizeText(
                          formatNum(mainTokenModel.delegationAmount, 4),
                          style: TextStyle(
                              color: Color(AppColors.BLACK),
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTokenView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      controller: _subTokenScrollController,
      itemCount: subTokenList.length,
      itemBuilder: (context, index) {
        return AssetSubTokenItem(
          wallet: wallet,
          tokenItem: subTokenList[index],
        );
      },
    );
  }

  void showChangeWalletDialog(BuildContext context) {
    showDialog(
        barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
        context: context,
        builder: (BuildContext context) {
          return WalletSwitchBottomSheet();
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
  void onResponseAssetData(Map<String, dynamic> response) {
    log('Asset.Resp = $response');
    if (subTokenList.isNotEmpty) {
      subTokenList.clear();
    }

    mainTokenModel = TokenItemModel(
        name: ChainParams.MAIN_TOKEN_SHORT_NAME,
        symbol: ChainParams.MAIN_TOKEN_DENOM);

    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        if (!EXCLUDE_SYMBOL.contains(f['symbol'])) {
          subTokenList
              .add(TokenItemModel(name: f['symbol'], symbol: f['symbol']));
        }
      });
    }
    setState(() {});

    SPUtils.getWalletAddress().then((address) {
      mPresenter.getBalance(address);
    });
  }

  @override
  void onResponseBalanceData(Map<String, dynamic> response) {
    log('Asset Balance.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        //MainToken
        if (f['denom'] == mainTokenModel.symbol) {
          mainTokenModel.amount =
              double.parse(f['amount']) / ChainParams.MAIN_TOKEN_UNIT;
        }

        if (!EXCLUDE_SYMBOL.contains(f['denom'])) {
          subTokenList.forEach((subToken) {
            if (f['denom'] == subToken.symbol) {
              subToken.amount =
                  double.parse(f['amount']) / ChainParams.MAIN_TOKEN_UNIT;
            }
          });
        }
      });
    }
    setState(() {});

    SPUtils.getWalletAddress().then((address) {
      mPresenter.getDelegationList(address);
    });
  }

  @override
  void onResponseDelegationData(Map<String, dynamic> response) {
    log('Asset Delegation.Resp = $response');

    setState(() {
      _saving = false;
    });

    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      double amount = 0;
      result.forEach((f) {
        amount += double.parse(f['shares']);
      });
      setState(() {
        mainTokenModel.delegationAmount = amount / ChainParams.MAIN_TOKEN_UNIT;
      });
    }
  }
}
