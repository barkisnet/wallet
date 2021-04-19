import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/asset/asset_page.dart';
import 'package:wallet/mvp/view/asset/asset_page_2.dart';
import 'package:wallet/mvp/view/delegation/delegation_page.dart';
import 'package:wallet/mvp/view/setting/setting_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_switch_drawer.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/config.dart';

///
/// 主页
///

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  var _currentIndex = 0;
  List<Widget> _pages;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pages = [
      (Config.ASSET_PAGE_STYLE == 1) ? AssetPage() : AssetPage2(),
      DelegationPage(),
      SettingPage(),
    ];

    _pageController = PageController(initialPage: _currentIndex);

    eventBus.on<OpenEndDrawer>().listen((event) {
      _scaffoldKey.currentState.openEndDrawer();
    });

    eventBus.on<ChangeMainPage>().listen((event) {
      setState(() {
        _currentIndex = 1;
      });
      _pageController.animateToPage(1,
          duration: Duration(microseconds: 1), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView.builder(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        unselectedFontSize: 14.0,
        selectedFontSize: 16.0,
        selectedItemColor: Color(AppColors.COLOR_PRIMARY),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                IconFont.ic_tab_asset,
                size: 20.0,
                color: Colors.grey,
              ),
              activeIcon: Icon(
                IconFont.ic_tab_asset,
                size: 20.0,
                color: Color(AppColors.COLOR_PRIMARY),
              ),
              title: FixedSizeText(
                FlutterI18n.translate(context, 'asset.title'),
                style: TextStyle(fontSize: 14.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                IconFont.ic_tab_delegate,
                size: 20.0,
                color: Colors.grey,
              ),
              activeIcon: Icon(
                IconFont.ic_tab_delegate,
                size: 20.0,
                color: Color(AppColors.COLOR_PRIMARY),
              ),
              title: FixedSizeText(
                FlutterI18n.translate(context, 'delegation.title'),
                style: TextStyle(fontSize: 14.0),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                IconFont.ic_tab_setting,
                size: 20.0,
                color: Colors.grey,
              ),
              activeIcon: Icon(
                IconFont.ic_tab_setting,
                size: 20.0,
                color: Color(AppColors.COLOR_PRIMARY),
              ),
              title: FixedSizeText(
                FlutterI18n.translate(context, 'setting'),
                style: TextStyle(fontSize: 14.0),
              ))
        ],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(index,
              duration: Duration(microseconds: 1), curve: Curves.ease);
        },
      ),
      endDrawer: WalletSwitchDrawer(),
      endDrawerEnableOpenDragGesture: _currentIndex == 0 ? true : false,
    );
  }
}
