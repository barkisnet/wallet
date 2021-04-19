import 'package:flutter/material.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// Tab 的 BottomNavigationBarItem 封装
///

class NavigationIconView {
  //item
  final BottomNavigationBarItem item;

  // title
  final String title;

  // icon path
  final IconData iconPath;

  // actived icon path
  final IconData activeIconPath;

  NavigationIconView(
      {@required this.title,
      @required this.iconPath,
      @required this.activeIconPath})
      : item = BottomNavigationBarItem(
            icon: Icon(
              iconPath,
              size: 20.0,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              activeIconPath,
              size: 20.0,
              color: Color(AppColors.COLOR_PRIMARY),
            ),
            title: FixedSizeText(
              title,
              style: TextStyle(fontSize: 14.0),
            ));
}
