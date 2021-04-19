import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/contract/wallet_import_contract.dart';
import 'package:wallet/mvp/presenter/wallet_import_presenter_impl.dart';
import 'package:wallet/mvp/view/main/main_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 导入钱包页面
///

class WalletImportPage extends StatefulWidget {
  @override
  _WalletImportPageState createState() => _WalletImportPageState();
}

class _WalletImportPageState extends State<WalletImportPage>
    implements WalletImportView {
  WalletImportPresenterImpl mPresenter;

  TextEditingController _mnemonicTextEditingController = TextEditingController();
  TextEditingController _walletNameTextEditingController = TextEditingController();
  TextEditingController _walletPasswordTextEditingController = TextEditingController();
  TextEditingController _walletRepasswordTextEditingController = TextEditingController();

  FocusNode _mnemonicFocusNode = FocusNode();
  FocusNode _walletNameFocusNode = FocusNode();
  FocusNode _walletPasswordFocusNode = FocusNode();
  FocusNode _walletRepasswordFocusNode = FocusNode();

  bool _saving = false;

  void _doImportWallet() {
    String walletName = _walletNameTextEditingController.text.trim();
    if (walletName.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.name_hint"));
      _walletNameFocusNode.requestFocus();
      return;
    }
    if (walletName.length < 1 || walletName.length > 30) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.name_limit"));
      _walletNameFocusNode.requestFocus();
      return;
    }

    String walletPassword = _walletPasswordTextEditingController.text;
    if (walletPassword == null || walletPassword.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.password_empty"));
      _walletPasswordFocusNode.requestFocus();
      return;
    }
    if (walletPassword.length != 6) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.password_limit"));
      _walletPasswordFocusNode.requestFocus();
      return;
    }
    String walletRepassword = _walletRepasswordTextEditingController.text;
    if (walletPassword != walletRepassword) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.password_inconsistent"));
      _walletRepasswordFocusNode.requestFocus();
      return;
    }

    String mnemonic = _mnemonicTextEditingController.text.trim();
    if (mnemonic == null || mnemonic.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.mnemonic_empty"));//助记词不能为空
      _mnemonicFocusNode.requestFocus();
      return;
    }
    if (!validateMnemonic(mnemonic)) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.mnemonic_invalid"));//无效的助记词;
      _mnemonicFocusNode.requestFocus();
      return;
    }

    DbHelper.instance.queryWalletByName(walletName).then((list){
      if(list.length > 0) {
        ToastUtils.show(FlutterI18n.translate(context, 'wallet.name_duplicated'));
      } else {
        final wallet = createWallet(mnemonic);
        String walletAddress = wallet.bech32Address;

        DbHelper.instance.queryWalletByAddress(walletAddress).then((wallet) {
          log('import.wallet = $wallet');
          if (wallet != null) {
            ToastUtils.show(FlutterI18n.translate(context, "wallet.mnemonic_exist"));//相同助记词的钱包已存在;
          } else {
            Map<String, dynamic> params = Map<String, dynamic>();
            params['mnemonic'] = mnemonic.replaceAll(RegExp(r"(\s+)"), " ");//把多余的空格给过滤掉
            params['name'] = walletName;
            params['address'] = walletAddress;
            params['password'] = walletPassword;
            params['selected'] = 1;
            params['createTime'] = DateTime.now().millisecondsSinceEpoch;
            log('params = $params');
            mPresenter.importWalletData(params);
          }
        });
      }
    });
  }

  @override
  void dismissLoading() {
    setState(() {
      _saving = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _saving = true;
    });
  }

  @override
  void showMessage(String msg) {
    setState(() {
      _saving = false;
    });
    ToastUtils.show(msg);
  }

  @override
  void onSuccess(Map<String, dynamic> response) {
    log('onSuccess = $response');
    this.showMessage(FlutterI18n.translate(context, "wallet.importing_success"));//'导入钱包成功！');
    SPUtils.setWalletInfo(response).then((value) {
      navPushAndRemoveAll(context, MainPage());
    });
  }

  @override
  void onFailure() {
    this.showMessage(FlutterI18n.translate(context, "wallet.importing_fail"));//'导入钱包成功！');
  }

  @override
  void initState() {
    super.initState();
    mPresenter = WalletImportPresenterImpl(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "wallet.import"),
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
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        progressIndicator: Container(
          width: SystemUtils.getWidth(context),
          height: SystemUtils.getHeight(context) - 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoActivityIndicator(),
              SizedBox(
                height: 8.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "wallet.importing"),//'正在导入中....',
                style:
                    TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),
              )
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            // 点击空白处收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: [
              SizedBox(height: 10.0),
              _buildInputMnemonicView(context),
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
      ),
    );
  }

  ///请输入助记词
  Widget _buildInputMnemonicView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: TextField(
        focusNode: _mnemonicFocusNode,
        controller: _mnemonicTextEditingController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLines: 5,
        style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
        onChanged: (val) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(context, "wallet.mnemonic_hint"),//请输入助记词（按空格分隔）
          hintStyle: TextStyle(color: Color(AppColors.GREY_2), fontSize: 14.0),
          contentPadding: EdgeInsets.only(
            left: 15.0,
            right: 10.0,
            top: 10.0,
            bottom: 10.0,
          ),
          border: InputBorder.none,
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
                hintText: FlutterI18n.translate(context, "wallet.password_confirm_hint"),
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
              FlutterI18n.translate(context, "wallet.password_limit"),
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
        onPressed: _doImportWallet,
        color: Color(AppColors.COLOR_PRIMARY),
        highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0))),
        child: Center(
          child: FixedSizeText(
            FlutterI18n.translate(context, "wallet.import"),
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
