import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';

import 'config.dart';
import 'welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //初始化数据库
  DbHelper.instance;

  FlutterBugly.postCatchedException((){
    SPUtils.getLanguageCode().then((languageCode){
      log('languageCode = $languageCode');
      SPUtils.getWalletAddress().then((value){
        log('Local.walletAddress = $value');
        if(value != null){
          runApp(WelcomePage(loginResult: 1, languageCode: languageCode,));
        } else {
          runApp(WelcomePage(loginResult: 0, languageCode: languageCode,));
        }
      });
    });
  });

  FlutterBugly.init(
    androidAppId: Config.BUGLY_ANDROID_APP_ID,
    iOSAppId: Config.BUGLY_IOS_APP_ID,
    autoDownloadOnWifi: true,
  ).then((_result) {
    log('appVersionInfo: ${_result.message}');
  });

//  runApp(WelcomePage(loginResult: 0));

  // 强制竖屏
//  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
//    runApp(WeatherApp());
//
//    if (Platform.isAndroid) {
//      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
//    }
//  });
}
