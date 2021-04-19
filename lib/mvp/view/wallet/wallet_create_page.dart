import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/wallet/wallet_backup_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 创建钱包页面
///
class WalletCreatePage extends StatefulWidget {
  @override
  _WalletCreatePageState createState() => _WalletCreatePageState();
}

class _WalletCreatePageState extends State<WalletCreatePage> {
  var mnemonicList = generateMnemonic().split(RegExp(r"(\s+)"));

  TextEditingController _walletNameTextEditingController = TextEditingController();
  TextEditingController _walletPasswordTextEditingController = TextEditingController();
  TextEditingController _walletRepasswordTextEditingController = TextEditingController();

  FocusNode _walletNameFocusNode = FocusNode();
  FocusNode _walletPasswordFocusNode = FocusNode();
  FocusNode _walletRepasswordFocusNode = FocusNode();

  bool _saving = false;

  void _verifyData() {
    String walletName = _walletNameTextEditingController.text.trim();
    String password = _walletPasswordTextEditingController.text.trim();
    String rePassword = _walletRepasswordTextEditingController.text.trim();

    if (walletName.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.name_hint"));
      _walletNameFocusNode.requestFocus();
      return;
    }
    if(walletName.length < 1 || walletName.length > 30){
       ToastUtils.show(FlutterI18n.translate(context, 'wallet.name_limit'));
       _walletNameFocusNode.requestFocus();
       return;
    }
    if(password.isEmpty){
      ToastUtils.show(FlutterI18n.translate(context, 'wallet.password_empty'));
      _walletPasswordFocusNode.requestFocus();
      return;
    }
    if(rePassword.isEmpty){
      ToastUtils.show(FlutterI18n.translate(context, 'wallet.password_confirm_empty'));
      _walletRepasswordFocusNode.requestFocus();
      return;
    }
    if(password.length != 6){
      ToastUtils.show(FlutterI18n.translate(context, 'wallet.password_limit'));
      _walletPasswordFocusNode.requestFocus();
      return;
    }
    if(password != rePassword){
      ToastUtils.show(FlutterI18n.translate(context, 'wallet.password_inconsistent'));
      _walletRepasswordFocusNode.requestFocus();
      return;
    }

    DbHelper.instance.queryWalletByName(walletName).then((list){
      if(list.length > 0) {
        ToastUtils.show(FlutterI18n.translate(context, 'wallet.name_duplicated'));
      } else {
        _doImportWallet();
      }
    });
  }

  void _doImportWallet() async {
    setState(() {
      _saving = true;
    });

    navPush(context, WalletBackupPage(mnemonicList, _walletNameTextEditingController.text, _walletRepasswordTextEditingController.text, shouldHideButton: false));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'wallet.create'),
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          // 点击空白处收起键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: [
            SizedBox(height: 10.0),
            _buildWalletNameView(context),
            SizedBox(height: 10.0),
            _buildWalletPasswordView(context),
            SizedBox(height: 30.0),
            _buildButtonView(context),
            SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  ///钱包名称
  Widget _buildWalletNameView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding:
          EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5), //边角为30
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconFont.ic_wallet,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "wallet.name"),
                style: TextStyle(
                    color: Color(AppColors.BLACK), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              color: Color(AppColors.MAIN_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: TextField(
              focusNode: _walletNameFocusNode,
              controller: _walletNameTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20)
              ],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "wallet.name_hint"),
                hintStyle:
                    TextStyle(color: Color(AppColors.GREY_2), fontSize: 14.0),
                contentPadding: EdgeInsets.only(
                  left: 15.0,
                  right: 10.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 10.0,
            ),
            child: FixedSizeText(
              FlutterI18n.translate(context, "wallet.name_limit"),
              style: TextStyle(
                color: Color(AppColors.GREY_2),
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///钱包密码
  Widget _buildWalletPasswordView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding:
          EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5), //边角为30
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconFont.ic_password,
                size: 18.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "wallet.password"),
                style: TextStyle(
                    color: Color(AppColors.BLACK), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              color: Color(AppColors.MAIN_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: TextField(
              focusNode: _walletPasswordFocusNode,
              controller: _walletPasswordTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)//限制长度
              ],
              maxLines: 1,
              obscureText: true,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "wallet.password_hint"),
                hintStyle:
                    TextStyle(color: Color(AppColors.GREY_2), fontSize: 14.0),
                contentPadding: EdgeInsets.only(
                  left: 15.0,
                  right: 10.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Color(AppColors.MAIN_COLOR),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: TextField(
              focusNode: _walletRepasswordFocusNode,
              controller: _walletRepasswordTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)//限制长度
              ],
              maxLines: 1,
              obscureText: true,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "wallet.password_confirm_hint"),//'请再次输入钱包密码',
                hintStyle:
                    TextStyle(color: Color(AppColors.GREY_2), fontSize: 14.0),
                contentPadding: EdgeInsets.only(
                  left: 15.0,
                  right: 10.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 10.0,
            ),
            child: FixedSizeText(
              FlutterI18n.translate(context, "wallet.password_limit"),//'密码长度为6位数字',
              style: TextStyle(
                color: Color(AppColors.GREY_2),
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildButtonView(BuildContext context) {
    return Container(
      height: 45.0,
      width: SystemUtils.getWidth(context) - 30.0,
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      child: RaisedButton(
        onPressed: _verifyData,
        color: Color(AppColors.COLOR_PRIMARY),
        highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0))),
        child: Center(
          child: FixedSizeText(
            FlutterI18n.translate(context, "button.next"),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
