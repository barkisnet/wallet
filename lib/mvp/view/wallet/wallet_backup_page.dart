import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/wallet/wallet_mnemonic_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 抄写助记词 页面
///

class WalletBackupPage extends StatefulWidget {
  List<String> mnemonicList;
  String walletName;
  String walletPassword;
  bool shouldHideButton;

  WalletBackupPage(this.mnemonicList, this.walletName, this.walletPassword, {this.shouldHideButton});

  @override
  _WalletBackupPageState createState() => _WalletBackupPageState();
}

class _WalletBackupPageState extends State<WalletBackupPage> {

  @override
  void initState() {
    super.initState();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, widget.shouldHideButton ? "wallet.mnemonic_export" : "wallet.mnemonic_write"),//'导出助记词' : '请抄写助记词',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
            child: Row(
              children: [
                Icon(
                  IconFont.ic_security,
                  color: Color(AppColors.COLOR_PRIMARY),
                  size: 30.0,
                ),
                SizedBox(width: 15.0),
                Expanded(
                    child: FixedSizeText(
                      FlutterI18n.translate(context, "wallet.mnemonic_tips_1"),
                      style: TextStyle(
                          color: Color(AppColors.GREY_1),
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          height: 1.5),
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
            child: Row(
              children: [
                Icon(
                  IconFont.ic_modify,
                  color: Color(AppColors.COLOR_PRIMARY),
                  size: 30.0,
                ),
                SizedBox(width: 15.0),
                Expanded(
                    child: FixedSizeText(
                  FlutterI18n.translate(context, "wallet.mnemonic_tips_2"),
                  style: TextStyle(
                      color: Color(AppColors.GREY_1),
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      height: 1.5),
                ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildMnemonicGridView(context),
          ),
          widget.shouldHideButton ? Offstage() : _buildButtonView(context),
        ],
      ),
    );
  }

  Widget _buildMnemonicGridView(BuildContext context) {
    log('mnemonicList.lenght = ${widget.mnemonicList.length}');
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        //GridView内边距
        padding: EdgeInsets.all(6.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //一行的Widget数量
          crossAxisCount: 4,
          //垂直子Widget之间间距
          mainAxisSpacing: 5.0,
          //水平子Widget之间间距
          crossAxisSpacing: 5.0,
          //子Widget宽高比例
          childAspectRatio: 2.0,
        ),
        itemCount: widget.mnemonicList.length,
        itemBuilder: (context, index) {
          log('mnemonicList[$index] = ${widget.mnemonicList[index]}');
          return Container(
            decoration: BoxDecoration(
              color: Color(AppColors.WHITE),
            ),
            alignment: Alignment.center,
            child: FixedSizeText(
              widget.mnemonicList[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.BLACK),
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            ),
          );
        });
  }

  Container _buildButtonView(BuildContext context) {
    return Container(
      height: 45.0,
      width: SystemUtils.getWidth(context) - 20.0,
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
      child: RaisedButton(
        onPressed: (){
          navPush(context, WalletMnemonicPage(widget.mnemonicList, widget.walletName, widget.walletPassword));
        },
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
