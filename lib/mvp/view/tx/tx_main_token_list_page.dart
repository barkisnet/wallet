import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/tx/tx_list_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// MainToken交易流水页面
///
class MainTokenTxListPage extends StatefulWidget {
  WalletModel wallet;

  MainTokenTxListPage({this.wallet});

  @override
  _MainTokenTxListPageState createState() => _MainTokenTxListPageState();
}

class _MainTokenTxListPageState extends State<MainTokenTxListPage> {
  var _currentIndex = 0;
  List<Widget> _pages;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pages = [
      TxListPage("in", ChainParams.MAIN_TOKEN_DENOM, widget.wallet.address),
      TxListPage("out", ChainParams.MAIN_TOKEN_DENOM, widget.wallet.address)
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
          '${ChainParams.MAIN_TOKEN_SHORT_NAME} ${FlutterI18n.translate(context, "tx.list")}',
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
      body: _buildTxTabView(context),
    );
  }

  Widget _buildTxTabView(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildIndicatorView(context),
          Expanded(child: _buildPagerView(context)),
        ],
      ),
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
