import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/contact/contact_page.dart';
import 'package:wallet/mvp/view/setting/about_page.dart';
import 'package:wallet/mvp/view/setting/language_page.dart';
import 'package:wallet/mvp/view/setting/webview_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/utils/version_manager.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/widget/common/setting_item_widget.dart';
import 'package:wallet/widget/dialog/update_dialog.dart';

///
/// 设置页面
///

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  VersionManager _versionManager;

  GlobalKey<UpdateDialogState> _dialogKey = new GlobalKey();

  UpgradeInfo _upgradeInfo;

  bool _newVersion = false;

  void checkNewVersion(){
//    FlutterBugly.setUserId("user id");
//    FlutterBugly.putUserData(key: "key", value: "value");
//    int tag = 9527;
//    FlutterBugly.setUserTag(tag);
    if (mounted) _checkUpgrade();
  }

  @override
  void initState() {
    super.initState();
    _versionManager = new VersionManager();
    if (Platform.isAndroid) {
      checkNewVersion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "setting"),
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(AppColors.WHITE),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(AppColors.MAIN_COLOR),
      body: Container(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 10.0),
            SettingItemWidget(
              iconData: IconFont.ic_contact_book,
              title: FlutterI18n.translate(context, "contact.list"),
              onItemClick: () {
                navPush(context, ContactPage(option: 1));
              },
            ),
            Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
            SettingItemWidget(
              iconData: IconFont.ic_wallet,
              title: FlutterI18n.translate(context, "wallet.title"),
              onItemClick: () {
                navPush(context, WalletManagerPage());
              },
            ),
            SizedBox(height: 10.0),
            _buildAuxiliaryFunctionsView(context),
            SizedBox(height: 10.0),
            SettingItemWidget(
              iconData: IconFont.ic_clear_cache,
              title: FlutterI18n.translate(context, "clear_cache"),
              onItemClick: () {
                ToastUtils.show(
                    FlutterI18n.translate(context, "clear_cache_finished"));
              },
            ),
            Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
            SettingItemWidget(
              iconData: IconFont.ic_multilanguage,
              title: FlutterI18n.translate(context, "language"),
              onItemClick: () {
                navPush(context, LanguagePage());
              },
            ),
            Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
            SettingItemWidget(
              iconData: IconFont.ic_info,
              title: FlutterI18n.translate(context, "about.title"),
              onItemClick: () {
                navPush(context, AboutPage());
              },
            ),
            SizedBox(height: 10.0),
            (!Platform.isAndroid) ? Offstage() : SettingItemWidget(
              iconData: IconFont.ic_new_version,
              title: FlutterI18n.translate(context, "new_version.check_update"),
              isVersion: _newVersion,
              subTitle: _newVersion ? FlutterI18n.translate(context, "new_version.exist_new_version") : FlutterI18n.translate(context, "new_version.no_new_version"),
              onItemClick: () {
                if (_upgradeInfo == null) {
                  _checkUpgrade();
                } else {
                  var newVersion = "${_upgradeInfo.versionName}+${_upgradeInfo.versionCode}";
                  _showUpdateDialog(newVersion, _upgradeInfo.newFeature, _upgradeInfo.apkUrl, _upgradeInfo.upgradeType == 2);
                }
              },
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildAuxiliaryFunctionsView(BuildContext context){
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SettingItemWidget(
          iconData: IconFont.ic_more,
          title: FlutterI18n.translate(context, "menu_dapp"),
          onItemClick: () {
            getDappInfo();
          },
        ),
        Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
        SettingItemWidget(
          iconData: IconFont.ic_node,
          title: FlutterI18n.translate(context, "menu_super_node"),
          onItemClick: () {
            navPush(context, WebviewPage(
              url: 'http://help.bksnet.io/node.html',
              titleText: FlutterI18n.translate(context, 'menu_super_node'),),
            );
          },
        ),
        Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
        SettingItemWidget(
          iconData: IconFont.ic_guide,
          title: FlutterI18n.translate(context, "menu_guides_app"),
          onItemClick: () {
            navPush(context, WebviewPage(
              url: 'http://help.bksnet.io/wallet.html',
              titleText: FlutterI18n.translate(context, 'menu_guides_app'),),
            );
          },
        ),
        Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
        SettingItemWidget(
          iconData: IconFont.ic_question,
          title: FlutterI18n.translate(context, "menu_Q_A"),
          onItemClick: () {
            navPush(context, WebviewPage(
              url: 'http://help.bksnet.io/issue.html',
              titleText: FlutterI18n.translate(context, 'menu_Q_A'),),
            );
          },
        ),
        Divider(height: 0.5, color: Color(AppColors.SP_LINE)),
        SettingItemWidget(
          iconData: IconFont.ic_contact_us,
          title: FlutterI18n.translate(context, "menu_contact_us"),
          onItemClick: () {
            navPush(context, WebviewPage(
              url: 'http://help.bksnet.io/contactus.html',
              titleText: FlutterI18n.translate(context, 'menu_contact_us'),),
            );
          },
        ),
      ],
    );
  }

  void _showDownloadFailed() {
    setState(() {
      _dialogKey?.currentState?.progress = 0.0;
    });
    ToastUtils.show(FlutterI18n.translate(context, "new_version.check_fail"));
  }

  void _showDownloadProgress(double _progress) {
    setState(() {
      _dialogKey?.currentState?.progress = _progress;
    });
  }

  void _downloadApk(String url) {
    _versionManager.downloadApk((_received, _total) {
      _showDownloadProgress(_received / _total);
    }, () {
      _showDownloadFailed();
    }, url);
  }

  Widget _buildDialog(String newVersion, String newFeature, String url, bool isForceUpgrade) {
    return WillPopScope(
        onWillPop: () async => isForceUpgrade,
        child: UpdateDialog(
          key: _dialogKey,
          newVersion: newVersion,
          newFeature: newFeature,
          onClickWhenDownload: (_msg) {
            //提示不要重复下载
            ToastUtils.show(FlutterI18n.translate(context, "new_version.do_not_repeat_download"));
          },
          onClickWhenNotDownload: () {
            //下载apk，完成后打开apk文件，建议使用dio+open_file插件
            _downloadApk(url);
          },
        ));
  }

  void _showUpdateDialog(String newVersion, String newFeature, String url, bool isForceUpgrade) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => _buildDialog(newVersion, newFeature, url, isForceUpgrade),
    );
  }

  void _checkUpgrade() {

    // 1.先检测本地是否有更新信息
    FlutterBugly.getUpgradeInfo().then((UpgradeInfo info) {
      log('UpgradeInfo = $info');
      if (info != null && info.id != null) { //2.本地有信息，直接显示更新窗口
        _upgradeInfo = info;
        setState(() {
          _newVersion = true;
        });
        var newVersion = "${info.versionName}+${info.versionCode}";
        _showUpdateDialog(newVersion, info.newFeature, info.apkUrl, info.upgradeType == 2);
      } else { //3.本地没有更新信息，连接远程服务器

        log("检测更新中");
        FlutterBugly.checkUpgrade().then((UpgradeInfo info) {
          log('UpgradeInfo = $info');
          if (info != null && info.id != null) {
            _upgradeInfo = info;
            log("----------------${info.apkUrl}");
            setState(() {
              _newVersion = true;
            });
            var newVersion = "${info.versionName}+${info.versionCode}";
            _showUpdateDialog(newVersion, info.newFeature, info.apkUrl, info.upgradeType == 2);
          } else {
            setState(() {
              _newVersion = false;
            });
//            Fluttertoast.cancel();
            log("没有新版本");
          }
        });
      }
    });
  }

  void getDappInfo() async {
    try {
      showWaitingDialog();
      SPUtils.getWalletAddress().then((walletAddress) async {
        SPUtils.getLanguageCode().then((languageCode) async {
          Response response = await Dio().get("http://wbksdappapi.staticbks.top/game/auth?address=$walletAddress&lang=$languageCode");
          Navigator.of(context).pop();
          log('$response');
          Map<String, dynamic> result = response.data;
          if(result['code'] == 1){
            String url = response.data['data']['url'];
            navPush(context, WebviewPage(
              url: url,
              titleText: FlutterI18n.translate(context, 'menu_dapp'),),
            );
          }
        });
      });
    } catch (e) {
      log(e);
    }
  }

  void showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_){
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SizedBox(
              width: 120.0,
              height: 120.0,
              child: Container(
                decoration: ShapeDecoration(
                  color: Color(AppColors.MAIN_COLOR),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: FixedSizeText(
                        FlutterI18n.translate(context, 'loading'),
                        style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

}
