import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 关于
///

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  String platformString = 'Android';

  String _appVersion;
  String _buildNumber;

  @override
  void initState() {
    super.initState();

    setState(() {
      if(Platform.isAndroid){
        platformString = 'Android';
      } else {
        platformString = 'iOS';
      }
    });

    SystemUtils.getPackageInfo().then((packageInfo) {
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "about.title"),
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(AppColors.WHITE),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
      body: Container(
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      'assets/images/logo_transparent.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FixedSizeText(
                    FlutterI18n.translate(context, "app_name", translationParams: {"tokenName": ChainParams.MAIN_TOKEN_FULL_NAME}),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(AppColors.BLACK), fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  FixedSizeText(
                    FlutterI18n.translate(context, "about.info",
                        translationParams: {
                          "organization": ChainParams.ORGANIZATION,
                          "platform": platformString
                        }),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15.0),
                  FixedSizeText(
                    'V$_appVersion(build $_buildNumber)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20.0,
              child: Container(
                alignment: Alignment.center,
                width: SystemUtils.getWidth(context),
                child: FixedSizeText(
                  FlutterI18n.translate(
                    context,
                    "about.copyright",
                    translationParams: {
                      "organization": ChainParams.ORGANIZATION
                    },
                  ),
                  style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
