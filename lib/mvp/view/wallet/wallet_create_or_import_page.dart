import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/wallet/wallet_create_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_import_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/chain_params.dart';

///
/// 钱包创建与导入页面
///

class WalletCreateOrImportPage extends StatefulWidget {
  @override
  _WalletCreateOrImportPageState createState() =>
      _WalletCreateOrImportPageState();
}

class _WalletCreateOrImportPageState extends State<WalletCreateOrImportPage> {
  String _appVersion;
  String _buildNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: SystemUtils.getHeight(context),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                buildLogo(context),
                SizedBox(height: 20.0),
                buildTitle(),
                SizedBox(height: 20.0),
                buildVersionText(context),
              ],
            ),
            Positioned(
              bottom: 80.0,
              child: buildCreateOrImportView(context),
            ),
          ],
        ),
      ),
    );
  }

  Center buildLogo(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  Center buildTitle() {
    return Center(
      child: FixedSizeText(
        FlutterI18n.translate(context, "app_name", translationParams: {"tokenName": ChainParams.MAIN_TOKEN_FULL_NAME}),
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container buildVersionText(BuildContext context) {
    SystemUtils.getPackageInfo().then((packageInfo) {
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    });

    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: FixedSizeText(
                'V$_appVersion(build $_buildNumber)',
                style: TextStyle(
                  color: Color(AppColors.GREY_2),
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildCreateOrImportView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                InkWell(
                  onTap: (){
                    navPush(context, WalletCreatePage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(IconFont.ic_creat_pocket, size: 64, color: Color(AppColors.GREEN),),
                  ),
                ),
                FixedSizeText(
                  FlutterI18n.translate(context, "wallet.create"),
                  style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0, fontWeight: FontWeight.bold),),
              ],
            ),
            Column(
              children: [
                InkWell(
                  onTap: (){
                    navPush(context, WalletImportPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(IconFont.ic_import_pocket, size: 64, color: Color(AppColors.BLUE),),
                  ),
                ),
                FixedSizeText(
                  FlutterI18n.translate(context, "wallet.import"),
                  style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0, fontWeight: FontWeight.bold),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
