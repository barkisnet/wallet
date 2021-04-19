import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/token_item_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/qr/qr_code_page.dart';
import 'package:wallet/mvp/view/tx/tx_list_page.dart';
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
/// SubToken资产页面
///

class AssetSubTokenPage extends StatefulWidget {
  WalletModel wallet;
  TokenItemModel tokenItem;

  AssetSubTokenPage({this.wallet, this.tokenItem});

  @override
  _AssetSubTokenPageState createState() => _AssetSubTokenPageState();
}

class _AssetSubTokenPageState extends State<AssetSubTokenPage>
    with SingleTickerProviderStateMixin {

  var _currentIndex = 0;
  List<Widget> _pages;
  PageController _pageController;

  List<Map<String, dynamic>> _tabTitleList = [
    {"key": "tx.in", "type": "in"},
    {"key": "tx.out", "type": "out"},
  ];

  Future scan() async {
    var result = await BarcodeScanner.scan();
    print('扫一扫结果：${result.rawContent}');
    navPush(
        context,
        TxSendPage(
            wallet: widget.wallet,
            denom: widget.tokenItem.symbol,
            availableAmount: widget.tokenItem.amount,
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

  @override
  void initState() {
    super.initState();
    _pages = [
      TxListPage('in', widget.tokenItem.symbol, widget.wallet.address),
      TxListPage('out', widget.tokenItem.symbol, widget.wallet.address)
    ];

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          '${widget.tokenItem.name.toUpperCase()} ${FlutterI18n.translate(context, "asset.title")}',
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(AppColors.WHITE),
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
      ),
      backgroundColor: Color(AppColors.WHITE),
      body: Container(
        child: Column(
          children: [
            _buildCardView(context),
            _buildGridView(context),
            Expanded(child: _buildTxTabView(context)),
          ],
        ),
      ),
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
                      formatNum(widget.tokenItem.amount, 6),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(
                      width: 6.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: FixedSizeText(
                        widget.tokenItem.symbol.toUpperCase(),
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
                        denom: widget.tokenItem.symbol,
                        availableAmount: widget.tokenItem.amount));
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

  Widget _buildTxTabView(BuildContext context) {
    return Column(
      children: [
        _buildIndicatorView(context),
        Expanded(child: _buildPagerView(context)),
      ],
    );
  }

  Widget _buildIndicatorView(BuildContext context) {
    return Container(
      height: 40.0,
      margin: EdgeInsets.only(left: 60.0, right: 60.0, top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        border: Border.all(color: Color(AppColors.SP_LINE), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Material(
            child: InkWell(
              onTap: (){
                setState(() {
                  _currentIndex = 0;
                });
                _pageController.animateToPage(0, duration: Duration(microseconds: 1), curve: Curves.ease);
              },
              child: Container(
                height: 40.0,
                width: (SystemUtils.getWidth(context) - 120) / 2 - 1,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  border: Border.all(color: _currentIndex == 0 ? Color(AppColors.COLOR_PRIMARY) : Colors.transparent, width: 1.0),
                ),
                child: FixedSizeText(
                  FlutterI18n.translate(context, "tx.in"),
                  style: TextStyle(color: Color(_currentIndex == 0 ? AppColors.COLOR_PRIMARY:AppColors.GREY_1), fontSize: 13.0),),
              ),
            ),
          ),
          Material(
            child: InkWell(
              onTap: (){
                setState(() {
                  _currentIndex = 1;
                });
                _pageController.animateToPage(1, duration: Duration(microseconds: 1), curve: Curves.ease);
              },
              child: Container(
                height: 40.0,
                width: (SystemUtils.getWidth(context) - 120) / 2 - 1,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  border: Border.all(color: _currentIndex == 1 ? Color(AppColors.COLOR_PRIMARY) : Colors.transparent, width: 1.0),
                ),
                child: FixedSizeText(
                  FlutterI18n.translate(context, "tx.out"),
                  style: TextStyle(color: Color(_currentIndex == 1 ? AppColors.COLOR_PRIMARY:AppColors.GREY_1), fontSize: 13.0),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagerView(BuildContext context) {
    return PageView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _pages[index];
      },
      controller: _pageController,
      itemCount: _pages.length,
      physics: NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
