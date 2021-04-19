import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/contract/wallet_create_contract.dart';
import 'package:wallet/mvp/presenter/wallet_create_presenter_impl.dart';
import 'package:wallet/mvp/view/main/main_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 验证助记词页面
///
class WalletMnemonicPage extends StatefulWidget {
  List<String> mnemonicList;
  String walletName;
  String walletPassword;

  WalletMnemonicPage(this.mnemonicList, this.walletName, this.walletPassword);

  @override
  _WalletMnemonicPageState createState() => _WalletMnemonicPageState();
}

class _WalletMnemonicPageState extends State<WalletMnemonicPage> implements WalletCreateView{
  WalletCreatePresenterImpl mPresenter;
  var rawMnemonicList = null;

  var verifyMnemonicList = List<String>();

  var pairWordMap = Map<int, String>();

  bool _saving = false;

  void onCommitClick() {
    bool isRight = true;
    widget.mnemonicList.asMap().forEach((index, e) {//验证助记词的顺序是否正确
      if(verifyMnemonicList[index] != e){
        isRight = false;
        return;
      }
    });

    if(!isRight) {
      ToastUtils.show(FlutterI18n.translate(context, "wallet.mnemonic_order"));//"助记词顺序不对");
      return;
    }

//    this.showMessage(FlutterI18n.translate(context, "wallet.creating"));//'正在创建钱包！');
    Map<String, dynamic> params = Map<String, dynamic>();
    String mnemonic = widget.mnemonicList.join(' ');
    params['mnemonic'] = mnemonic;
    params['name'] = widget.walletName;
    final wallet = createWallet(mnemonic);
    params['address'] = wallet.bech32Address;
    params['password'] = widget.walletPassword;
    params['selected'] = 1;
    params['createTime'] = DateTime.now().millisecondsSinceEpoch;
    log('create wallet params = $params');
    mPresenter.createWalletData(params);
  }

  @override
  void initState() {
    super.initState();
    mPresenter = WalletCreatePresenterImpl(this);
    //重新随机排列
    this.rawMnemonicList = widget.mnemonicList.sublist(0);
    rawMnemonicList.shuffle();

    setState(() {});
  }

  @override
  void onSuccess(Map<String, dynamic> response) {
    log('onSuccess = $response');
    this.showMessage(FlutterI18n.translate(context, "wallet.creating_success"));
    SPUtils.setWalletInfo(response).then((value) {
      navPushAndRemoveAll(context, MainPage());
    });
  }

  @override
  void onFailure() {
    this.showMessage(FlutterI18n.translate(context, "wallet.creating_fail"));
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "wallet.mnemonic_verify"),//'验证助记词',
          style: TextStyle(
            color: Color(AppColors.BLACK),
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
        actions: [
          InkWell(
            onTap: () {
              verifyMnemonicList.forEach((word) {
                pairWordMap.forEach((key, value) {
                  if (word == value) {
                    rawMnemonicList[key] = word;
                  }
                });
              });
              pairWordMap.clear();
              verifyMnemonicList.clear();

              setState(() {});
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.clear"),//'清空',
                  style: TextStyle(
                      color: Color(AppColors.RED),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 20.0, bottom: 15.0),
              child: FixedSizeText(
                FlutterI18n.translate(context, "wallet.mnemonic_click_tips"),//请按顺序点击助记词，确认您已正确备份。',
                style: TextStyle(
                    color: Color(AppColors.GREY_1),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    height: 1.5),
              ),
            ),
            Container(
              height: 200.0,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(AppColors.WHITE),
              ),
              child: _buildVerifyMnemonicGridView(context),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: _buildMnemonicGridView(context),
            ),
            _buildButtonView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyMnemonicGridView(BuildContext context) {
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
        itemCount: verifyMnemonicList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              String word = verifyMnemonicList[index];
              int i = -1;
              pairWordMap.forEach((key, value) {
                if (word == value) {
                  rawMnemonicList[key] = word;
                  i = key;
                }
              });
              pairWordMap.remove(i);

              verifyMnemonicList.removeAt(index);
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(AppColors.COLOR_PRIMARY),
              ),
              alignment: Alignment.center,
              child: FixedSizeText(
                verifyMnemonicList[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(AppColors.WHITE),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        });
  }

  Widget _buildMnemonicGridView(BuildContext context) {
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
        itemCount: rawMnemonicList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              String word = rawMnemonicList[index];
              if(word.isEmpty) {
                return;
              }
              verifyMnemonicList.add(word);
              pairWordMap[index] = rawMnemonicList[index];
              rawMnemonicList[index] = '';

              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: rawMnemonicList[index].isEmpty
                    ? Color(AppColors.GREY_3)
                    : Color(AppColors.WHITE),
              ),
              alignment: Alignment.center,
              child: FixedSizeText(
                rawMnemonicList[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(AppColors.BLACK),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        });
  }

  Container _buildButtonView(BuildContext context) {
    return Container(
      height: 45.0,
      width: SystemUtils.getWidth(context) - 20.0,
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
      child: RaisedButton(
        onPressed: verifyMnemonicList.length == 12 ? onCommitClick : null,
        color: verifyMnemonicList.length == 12 ? Color(AppColors.COLOR_PRIMARY) : Color(AppColors.GREY_2),
        highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0))),
        child: Center(
          child: FixedSizeText(
            FlutterI18n.translate(context, "button.ok"),
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
