import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sacco/models/transaction_result.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/net/tx_service.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 通证发行
///

class IssueTokenPage extends StatefulWidget {
  WalletModel wallet;
  Set<String> symbols;

  IssueTokenPage(this.wallet, this.symbols);

  @override
  _IssueTokenPageState createState() => _IssueTokenPageState();
}

class _IssueTokenPageState extends State<IssueTokenPage> {

  TextEditingController _isssueNameTextEditingController = TextEditingController();
  TextEditingController _issueDescTextEditingController = TextEditingController();
  TextEditingController _issueTotalTextEditingController = TextEditingController();

  FocusNode _isssueNameFocusNode = FocusNode();
  FocusNode _issueDescFocusNode = FocusNode();
  FocusNode _issueTotalFocusNode = FocusNode();

  bool _mintable = false;

  bool _sending = false;

  void _verifyData() {
    String tokenName = _isssueNameTextEditingController.text;
    String tokenDesc = _issueDescTextEditingController.text;
    String totalSupply = _issueTotalTextEditingController.text;

    // 通证发行需要支付2000个token作为手续费，并支付0.1个网络费
    if (widget.wallet.balance < (2000 + 0.1) * ChainParams.MAIN_TOKEN_UNIT) {
      ToastUtils.show(FlutterI18n.translate(
          context, 'issue.toast_insufficient_account_balance'));
      return;
    }

    if (widget.symbols.contains(tokenName)) {
      ToastUtils.show(FlutterI18n.translate(context, 'issue.toast_issue_name_duplicate'));
      _isssueNameFocusNode.requestFocus();
      return;
    }

    if(tokenName.isEmpty || tokenName.length < 3 || tokenName.length > 12){
      ToastUtils.show(FlutterI18n.translate(context, 'issue.token_name_tip'));
      _isssueNameFocusNode.requestFocus();
      return;
    }

    if (tokenDesc.isEmpty || tokenDesc.length > 80) {
      ToastUtils.show(FlutterI18n.translate(context, 'issue.toast_issue_desc_constraint'));
      _issueDescFocusNode.requestFocus();
      return;
    }

    if (totalSupply.isEmpty || double.parse(totalSupply) < 100 || double.parse(totalSupply) > 100000000000) {
      ToastUtils.show(FlutterI18n.translate(context, 'issue.toast_total_supply_constraint'));
      _issueTotalFocusNode.requestFocus();
      return;
    }

    ///隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());

    WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, _issueToken);
  }

  void _issueToken(BuildContext context) {
    setState(() {
      _sending = true;
    });

    String tokenName = _isssueNameTextEditingController.text.trim();
    String tokenDesc = _issueDescTextEditingController.text.trim();
    String total = _issueTotalTextEditingController.text.trim();

    Future<TransactionResult> f = TxService.issueToken(widget.wallet.mnemonic, tokenName, tokenName, total, _mintable, tokenDesc);

    f.then((tr) {
      setState(() {
        _sending = false;
      });
      if (tr.success) {
        ToastUtils.show(FlutterI18n.translate(context, "issue.issue_success"));
        navPop(context);
      } else {
        ToastUtils.show(FlutterI18n.translate(context, "issue.issue_fail",
            translationParams: {
              "error": tr.error.errorMessage
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'issue.title_issue_token'),
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
      backgroundColor: Color(AppColors.MAIN_COLOR),
      body: ModalProgressHUD(
        inAsyncCall: _sending,
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
                FlutterI18n.translate(context, "issue.issuing_token"),
                style: TextStyle(
                    color: Color(AppColors.COLOR_PRIMARY), fontSize: 14.0),
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
              _buildTokenNameView(context),
              SizedBox(height: 10.0),
              _buildTokenDesclView(context),
              SizedBox(height: 10.0),
              _buildTotalSupplyView(context),
              SizedBox(height: 10.0),
              _buildIsMintableView(context),
              SizedBox(height: 10.0),
              _buildIssueTipView(context),
              SizedBox(height: 30.0),
              _buildButtonView(context),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  ///名称
  Widget _buildTokenNameView(BuildContext context) {
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
                IconFont.ic_get_money_address,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, 'issue.token_name'),
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
              focusNode: _isssueNameFocusNode,
              controller: _isssueNameTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              inputFormatters: [
                //只允许输入小写字母
                WhitelistingTextInputFormatter(RegExp("[a-z]")),
                LengthLimitingTextInputFormatter(12) //限制长度
              ],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "issue.token_name_hint"),
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
              FlutterI18n.translate(context, "issue.token_name_tip"),
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

  ///描述
  Widget _buildTokenDesclView(BuildContext context) {
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
                IconFont.ic_note_write,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "issue.token_desc"),
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
              focusNode: _issueDescFocusNode,
              controller: _issueDescTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              maxLines: 2,
              maxLength: 80,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "issue.token_desc_hint"),
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
              FlutterI18n.translate(context, "issue.token_desc_tip"),
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

  ///总量
  Widget _buildTotalSupplyView(BuildContext context) {
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
                IconFont.ic_total_number,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "issue.total_supply"),
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
              focusNode: _issueTotalFocusNode,
              controller: _issueTotalTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12) //限制长度
              ],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "issue.total_supply_hint"),
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
              FlutterI18n.translate(context, "issue.total_supply_tip"),
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

  ///是否增发
  Widget _buildIsMintableView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding:
      EdgeInsets.only(left: 0.0, right: 10.0, top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5), //边角为30
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Color(AppColors.WHITE),
            child: InkWell(
              onTap: (){
                setState(() {
                  _mintable = !_mintable;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  IconFont.ic_check_cirle,
                  size: 20.0,
                  color: Color(_mintable ? AppColors.COLOR_PRIMARY : AppColors.GREY_1),
                ),
              ),
            ),
          ),
          FixedSizeText(
            FlutterI18n.translate(context, "issue.label_issue_token_mintable"),
            style: TextStyle(
                color: Color(AppColors.BLACK), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  ///提示信息
  Widget _buildIssueTipView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding:
      EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 0.0),
      child: FixedSizeText(
        FlutterI18n.translate(context, "issue.tip_issue_tokens",
            translationParams: {
              "issueTokenFee": ChainParams.ISSUE_TOKEN_FEE,
            }),
        style: TextStyle(
            color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold, height: 1.5),
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
            FlutterI18n.translate(context, "issue.label_issue"),
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
