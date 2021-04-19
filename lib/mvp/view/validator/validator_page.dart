import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/mvp/view/validator/validator_list_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 验证人 页面
///

class ValidatorPage extends StatefulWidget {
  @override
  _ValidatorPageState createState() => _ValidatorPageState();
}

class _ValidatorPageState extends State<ValidatorPage> {

  var _currentIndex = 0;
  List<Widget> _pages;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pages = [
      ValidatorListPage(validatorStatus: 'active'),
      ValidatorListPage(validatorStatus: 'inactive'),
    ];

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
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
      margin: EdgeInsets.only(left: 50.0, right: 50.0, top: 6.0, bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        border: Border.all(color: Color(AppColors.SP_LINE), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                _currentIndex = 0;
              });
              _pageController.animateToPage(0, duration: Duration(microseconds: 1), curve: Curves.ease);
            },
            child: Container(
              height: 40.0,
              width: (SystemUtils.getWidth(context) - 100) / 2 - 1,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(color: _currentIndex == 0 ? Color(AppColors.COLOR_PRIMARY) : Colors.transparent, width: 1.0),
              ),
              child: FixedSizeText(
                  FlutterI18n.translate(context, "validator.active"),
                style: TextStyle(color: Color(_currentIndex == 0 ? AppColors.COLOR_PRIMARY:AppColors.GREY_1), fontSize: 13.0),),
            ),
          ),
          InkWell(
            onTap: (){
              setState(() {
                _currentIndex = 1;
              });
              _pageController.animateToPage(1, duration: Duration(microseconds: 1), curve: Curves.ease);
            },
            child: Container(
              height: 40.0,
              width: (SystemUtils.getWidth(context) - 100) / 2 - 1,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(color: _currentIndex == 1 ? Color(AppColors.COLOR_PRIMARY) : Colors.transparent, width: 1.0),
              ),
              child: FixedSizeText(
                FlutterI18n.translate(context, "validator.inactive"),
                style: TextStyle(color: Color(_currentIndex == 1 ? AppColors.COLOR_PRIMARY:AppColors.GREY_1), fontSize: 13.0),),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagerView(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      itemBuilder: (BuildContext context, int index) {
        return _pages[index];
      },
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
