import 'package:flutter/material.dart';

///
/// 跳转页面、路由 工具类
///

void navPush(BuildContext context, Widget page){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
}

/// 跳转并关闭当前页面
void navPushAndRemoveCurrentStack(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => page), (route) => route == null,);
}

/// 跳转页面并关闭之前所有页面
void navPushAndRemoveAll(BuildContext context, Widget page){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => page), (check) => false);
}

/// 跳转登录页面并关闭所有页面
//void navPushRelogin(BuildContext context){
//  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (check) => false);
//}

void navPop(BuildContext context) {
  Navigator.of(context).pop();
}

void navPushNamed(BuildContext context, String routeName){
  Navigator.of(context).pushNamed(routeName);
}

void navPushNamedWithArguments(BuildContext context, String routeName, Map<String, dynamic> arguments){
  Navigator.of(context).pushNamed(routeName, arguments: arguments);
}

void navPushNamedAndRemoveUntil(BuildContext context, String routeName){
  Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => route == null);
}

void navPopUntil(BuildContext context, String routeName){
  Navigator.of(context).popUntil(ModalRoute.withName(routeName));
}

void navPopAndPushNamed(BuildContext context, String routeName){
  Navigator.of(context).popAndPushNamed(routeName);
}