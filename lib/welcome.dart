import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wallet/chain_params.dart';

import 'mvp/view/main/main_page.dart';
import 'mvp/view/wallet/wallet_create_or_import_page.dart';
import 'utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';

///
/// 欢迎页
///

class WelcomePage extends StatelessWidget {
  int loginResult = 0;
  String languageCode;

  WelcomePage({this.loginResult, this.languageCode});

  //statusBar设置为透明，去除半透明遮罩
  final SystemUiOverlayStyle _style = SystemUiOverlayStyle(statusBarColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    log("WelcomePage, languageCode=$languageCode");
    //将style设置到app
    SystemChrome.setSystemUIOverlayStyle(_style);
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(AppColors.COLOR_PRIMARY),
        appBarTheme: AppBarTheme(brightness: Brightness.light), // light为黑色 dark为白色
      ),
      debugShowCheckedModeBanner: false,
      // 利用下面这种方式来对title属性进行国际化操作，避免直接设置title，那样无法国际化
      onGenerateTitle: (context) => FlutterI18n.translate(context, "app_name", translationParams: {"tokenName": ChainParams.MAIN_TOKEN_FULL_NAME}),
      localizationsDelegates: [
        //应用程序的翻译回调
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
              useCountryCode: false,
              fallbackFile: languageCode,
              basePath: 'assets/i18n',
              forcedLocale: Locale(languageCode),
              decodeStrategies: [YamlDecodeStrategy()]),
        ),
        // 本地化的代理类
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate, //Material组件的翻译回调
        GlobalWidgetsLocalizations.delegate, //普通Widget的翻译回调
      ],
      locale: Locale(languageCode,''),
      supportedLocales: [ // 添加区域
        const Locale('en', ''), // English
        const Locale('zh', ''), // Chinese
        // 可以继续添加我们想要支持的语言类型
      ],
      home: loginResult == 0 ? WalletCreateOrImportPage() : MainPage(),
    );
  }
}
