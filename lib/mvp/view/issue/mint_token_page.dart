import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sacco/models/transaction_result.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/issue_token_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/net/tx_service.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 通证增发
///

class MintTokenPage extends StatefulWidget {
  WalletModel wallet;
  IssueTokenModel token;

  MintTokenPage(this.wallet, this.token);

  @override
  _MintTokenPageState createState() => _MintTokenPageState();
}

class _MintTokenPageState extends State<MintTokenPage> {

  TextEditingController _mintableAmountTextEditingController = TextEditingController(text: "0");

  FocusNode _mintableAmountFocusNode = FocusNode();

  bool _sending = false;

  void _verifyData() {
    String mintableAmount = _mintableAmountTextEditingController.text;

    if (mintableAmount.isEmpty || double.parse(mintableAmount) < 100 ||
        double.parse(mintableAmount) > 100000000000 ||
        (double.parse(mintableAmount) + widget.token.total / ChainParams.SUB_TOKEN_UNIT) > 100000000000) {
      ToastUtils.show(FlutterI18n.translate(context, 'issue.mintable_amount_constraint'));
      _mintableAmountFocusNode.requestFocus();
      return;
    }

    ///隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());

    WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, _mintToken);
  }

  void _mintToken(BuildContext context) {
    setState(() {
      _sending = true;
    });

    String mintableAmount = _mintableAmountTextEditingController.text.trim();

    Future<TransactionResult> f = TxService.mintToken(widget.wallet.mnemonic, widget.token.symbol, mintableAmount);

    f.then((tr) {
      setState(() {
        _sending = false;
      });
      if (tr.success) {
        ToastUtils.show(FlutterI18n.translate(context, "issue.mint_success"));
        navPop(context);
      } else {
        ToastUtils.show(FlutterI18n.translate(context, "issue.mint_fail",
            translationParams: {
              "error": tr.error.errorMessage
            }));
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'issue.title_token_mint'),
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
                FlutterI18n.translate(context, "issue.minting_token"),
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
              _buildTokenDescView(context),
              SizedBox(height: 10.0),
              _buildMintableAmountView(context),
              SizedBox(height: 10.0),
              _buildIssueTotalView(context),
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
              controller: TextEditingController(text: widget.token.symbol),
              readOnly: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "issue.hint_name"),
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
        ],
      ),
    );
  }

  ///描述
  Widget _buildTokenDescView(BuildContext context) {
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
              controller: TextEditingController(text: widget.token.desc),
              readOnly: true,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
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
        ],
      ),
    );
  }

  ///增发数量
  Widget _buildMintableAmountView(BuildContext context) {
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
                IconFont.ic_increase_number,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "issue.mintable_amount"),
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
              focusNode: _mintableAmountFocusNode,
              controller: _mintableAmountTextEditingController,
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
                hintText: FlutterI18n.translate(context, "issue.mintable_amount_hint"),
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
              FlutterI18n.translate(context, "issue.mintable_amount_constraint"),
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

  ///原始总量/总量
  Widget _buildIssueTotalView(BuildContext context) {
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
                FlutterI18n.translate(context, "issue.label_original_total_amount"),
                style: TextStyle(
                    color: Color(AppColors.BLACK), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: Row(
              children: [
                FixedSizeText(
                  '${formatNum(widget.token.total / ChainParams.SUB_TOKEN_UNIT, 6)} / ',
                  style: TextStyle(
                      color: Color(AppColors.GREY_2), fontWeight: FontWeight.bold),
                ),
                FixedSizeText(
                  '${formatNum((widget.token.total + double.parse(_mintableAmountTextEditingController.text.isEmpty ? "0" : _mintableAmountTextEditingController.text) * ChainParams.SUB_TOKEN_UNIT) / ChainParams.SUB_TOKEN_UNIT, 6)}',
                  style: TextStyle(
                      color: Color(AppColors.GREY_1), fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
      EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 0.0),
      child: FixedSizeText(
        FlutterI18n.translate(context, "issue.tip_mint_tokens",
            translationParams: {
              "mintTokenFee": ChainParams.MINT_TOKEN_FEE
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
            FlutterI18n.translate(context, "issue.label_mint"),
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
