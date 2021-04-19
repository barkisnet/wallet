import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sacco/models/transaction_result.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/net/tx_service.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/widget/common/round_slider_track_shape.dart';
import 'package:wallet/widget/common/text_input_formatter.dart';

///
/// 委托、赎回、领取收益、领取佣金公用这个页面
///

class DelegationTxPage extends StatefulWidget {
  String type; //区分委托、赎回、领取收益、领取佣金
  double amount = 0;
  String validatorAddress;
  WalletModel wallet;
  //这是余额字段，在解委托、领取收益、领取佣金的用来判断账户是否有足够的手续费
  double balance = 0;

  DelegationTxPage(
      {this.type,
      this.validatorAddress,
      this.wallet,
      this.amount = 0,
      this.balance = 0});

  @override
  _DelegationTxPageState createState() => _DelegationTxPageState();
}

class _DelegationTxPageState extends State<DelegationTxPage> {
  TextEditingController _sendAmountTextEditingController = TextEditingController();
  TextEditingController _memoTextEditingController = TextEditingController();

  FocusNode _sendAmountFocusNode = FocusNode();
  FocusNode _memoFocusNode = FocusNode();
  FocusNode _netfeeFocusNode = FocusNode();

  String gasAmountValueText = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE.toString();

  double showSeekbarValue = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE;

  bool _isCustomNetFee = false;

  bool _sending = false;

  String _title = "";
  String _hintForAmount = "";
  String _tipForAmount = "";

  void _verifyTxData() {
    String amountText = _sendAmountTextEditingController.text.trim().replaceAll(RegExp(r","), "");
    if (amountText.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "delegation.amount_empty"));
      _sendAmountFocusNode.requestFocus();
      return;
    }

    double amount = double.parse(amountText);
    double gasAmount = double.parse(gasAmountValueText.trim().replaceAll(RegExp(r","), ""));

    // 手续费不能低于设定的默认值，不能高于3倍
    if (gasAmount < ChainParams.DEFAULT_DELEGATION_NETWORK_FEE ||
        gasAmount > ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3) {
      ToastUtils.show(FlutterI18n.translate(context, "delegation.network_fee_hint",
          translationParams: {
            "min": ChainParams.DEFAULT_DELEGATION_NETWORK_FEE.toStringAsFixed(3),
            "max": (ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3).toStringAsFixed(3)
          }));
      _netfeeFocusNode.requestFocus();
      return;
    }

    if (widget.type == 'delegation') {
      if (widget.amount < amount + gasAmount + ChainParams.DEFAULT_DELEGATION_NETWORK_FEE) {
        ToastUtils.show(FlutterI18n.translate(
            context, "delegation.balance_insufficient", translationParams: {
          "networkFee": ChainParams.DEFAULT_DELEGATION_NETWORK_FEE.toString()
        }));
        _netfeeFocusNode.requestFocus();
        return;
      }
    } else if (widget.type == 'undelegation') {
      if (widget.balance < gasAmount) {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.network_fee_less_than_balance"));
        _sendAmountFocusNode.requestFocus();
        return;
      }

      if (widget.amount < amount) {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.delegation_insufficient"));
        _sendAmountFocusNode.requestFocus();
        return;
      }
    } else if (widget.type == 'reward') {
      if (widget.balance < gasAmount) {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.network_fee_less_than_balance"));
        _sendAmountFocusNode.requestFocus();
        return;
      }
    } else {
      if (widget.balance < gasAmount) {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.network_fee_less_than_balance"));
        _sendAmountFocusNode.requestFocus();
        return;
      }
    }

    ///隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());

    WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, _doDelegationTx);
  }

  void _doDelegationTx(BuildContext context) {
    double gasAmount = double.parse(gasAmountValueText);
    String memo = _memoTextEditingController.text.trim();

    setState(() {
      _sending = true;
    });
    Future<TransactionResult> f = null;
    if (widget.type == 'delegation') {
      double amount = double.parse(_sendAmountTextEditingController.text.trim().replaceAll(RegExp(r","), ""));
      f = TxService.delegate(widget.wallet.mnemonic, widget.validatorAddress, amount, gasAmount, memo);
    } else if (widget.type == 'undelegation') {
      double amount = double.parse(_sendAmountTextEditingController.text.trim().replaceAll(RegExp(r","), ""));
      f = TxService.undelegate(widget.wallet.mnemonic, widget.validatorAddress, amount, gasAmount, memo);
    } else if (widget.type == 'reward') {
      f = TxService.withdrawReward(widget.wallet.mnemonic, widget.validatorAddress, gasAmount, memo);
    } else {
      var valoperAddress = convertWalletAddressToValoperAddress(widget.validatorAddress);
      f = TxService.withdrawCommission(widget.wallet.mnemonic, valoperAddress, gasAmount, memo);
    }

    f.then((tr) {
      setState(() {
        _sending = false;
      });
      if (tr.success) {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.tx_success",
            translationParams: {"action": _title}));
        navPop(context);
      } else {
        ToastUtils.show(FlutterI18n.translate(context, "delegation.tx_fail",
            translationParams: {
              "action": _title,
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
    if (widget.type == 'delegation') {
      _title = FlutterI18n.translate(context, "delegation.title"); //'委托';
      _hintForAmount = FlutterI18n.translate(
          context, "delegation.delegate_hint"); //"请输入委托数量";
      _tipForAmount = FlutterI18n.translate(context, "delegation.delegate_tip",
          translationParams: {
            "amount": formatNum(widget.amount, 6),
            "unit": ChainParams.MAIN_TOKEN_SHORT_NAME,
            "networkFee": ChainParams.DEFAULT_DELEGATION_NETWORK_FEE.toString()
          }); //可委托数量
    } else if (widget.type == 'undelegation') {
      _title = FlutterI18n.translate(context, "delegation.undelegation"); //'赎回';
      _hintForAmount = FlutterI18n.translate(context, "delegation.undelegate_hint"); //"请输入赎回数量";
      _tipForAmount = FlutterI18n.translate(context, "delegation.undelegate_tip", translationParams: {
        "amount": formatNum(widget.amount, 6),
        "unit": ChainParams.MAIN_TOKEN_SHORT_NAME
      }); //可赎回数量
    } else if (widget.type == 'reward') {
      _title = FlutterI18n.translate(context, "validator.withdraw_reward_title"); //'领取收益';
      _hintForAmount = formatNum(widget.amount, 6);
      _sendAmountTextEditingController.text = _hintForAmount;
      _tipForAmount = FlutterI18n.translate(context, "delegation.reward_tip"); //"将一次领取完截止到当前时间的所有收益，不可拆分";
    } else {
      _title = FlutterI18n.translate(context, "validator.withdraw_commission_title"); //'领取佣金';
      _hintForAmount = formatNum(widget.amount, 6);
      _sendAmountTextEditingController.text = _hintForAmount;
      _tipForAmount = FlutterI18n.translate(context, "validator.commission_tip");
    }
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          _title,
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1.0,
        backgroundColor: Color(AppColors.WHITE),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
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
                FlutterI18n.translate(context, "delegation.sending", translationParams: {"actionType": _title}),
                style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 点击空白处收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: [
              SizedBox(height: 15.0),
              _buildAmountView(context),
              SizedBox(height: 10.0),
              _buildMemoView(context),
              SizedBox(height: 10.0),
              _buildNetfeeView(context),
              SizedBox(height: 30.0),
              _buildButtonView(context),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  ///数量
  Widget _buildAmountView(BuildContext context) {
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
                IconFont.ic_pay,
                size: 20.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "tx.amount"),
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
              focusNode: _sendAmountFocusNode,
              controller: _sendAmountTextEditingController,
              readOnly: (widget.type == 'reward' || widget.type == 'commission'),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalNumberTextInputFormatter(digit: 6)],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: _hintForAmount,
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
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 10.0,
            ),
            child: FixedSizeText(
              _tipForAmount,
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

  ///备注
  Widget _buildMemoView(BuildContext context) {
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
                size: 20.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "contact.remark"),
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
              focusNode: _memoFocusNode,
              controller: _memoTextEditingController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              maxLines: 2,
              maxLength: 50,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "contact.remark_hint"),
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
              FlutterI18n.translate(context, "contact.remark_tips"),
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

  ///网络费用
  Widget _buildNetfeeView(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    IconFont.ic_net_fee1,
                    size: 20.0,
                    color: Color(AppColors.GREY_1),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "tx.network_fee"), //'网络费用'
                    style: TextStyle(
                        color: Color(AppColors.BLACK),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Material(
                    color: Color(AppColors.WHITE),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isCustomNetFee = !_isCustomNetFee;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          IconFont.ic_check_cirle,
                          size: 20.0,
                          color: Color(_isCustomNetFee ? AppColors.COLOR_PRIMARY : AppColors.GREY_1),
                        ),
                      ),
                    ),
                  ),
                  FixedSizeText(
                    FlutterI18n.translate(context, "tx.network_custom_fee"),
                    //'自定义网络费用'
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
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
              focusNode: _netfeeFocusNode,
              controller: TextEditingController.fromValue(TextEditingValue(
                  text: gasAmountValueText,
                  // 保持光标在最后
                  selection: TextSelection.fromPosition(TextPosition(
                      affinity: TextAffinity.downstream,
                      offset: gasAmountValueText.length))
              )),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalNumberTextInputFormatter(digit: 6)],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {
                  log('textField.text = $val');
                  gasAmountValueText = val;
                  if(val.isEmpty){
                    showSeekbarValue = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE;
                  } else {
                    if(val != '0.00' && val != '0.0' && val != '0.' && val != '0'){
                      if(double.parse(val) < ChainParams.DEFAULT_DELEGATION_NETWORK_FEE){
                        showSeekbarValue = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE;
                      } else if(double.parse(val) > ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3){
                        showSeekbarValue = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3;
                      } else {
                        showSeekbarValue = double.parse(gasAmountValueText);
                      }
                    } else {
                      showSeekbarValue = ChainParams.DEFAULT_DELEGATION_NETWORK_FEE;
                    }
                  }
                });
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "delegation.network_fee_hint",
                    translationParams: {
                      "min": ChainParams.DEFAULT_DELEGATION_NETWORK_FEE.toStringAsFixed(3),
                      "max": (ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3).toStringAsFixed(3)
                    }),
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
          _isCustomNetFee
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        IconFont.ic_tortoise,
                        size: 22.0,
                        color: Color(AppColors.COLOR_PRIMARY),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Color(AppColors.COLOR_PRIMARY), //进度条滑块左边颜色
                              inactiveTrackColor: Color(AppColors.MAIN_COLOR), //进度条滑块右边颜色
                              trackShape: RoundSliderTrackShape(radius: 6), //进度条形状,这边自定义两头显示圆角
                              thumbColor: Color(AppColors.COLOR_PRIMARY), //滑块颜色
                              thumbShape: RoundSliderThumbShape( //可继承SliderComponentShape自定义形状
                                disabledThumbRadius: 6, //禁用是滑块大小
                                enabledThumbRadius: 6, //滑块大小
                              ),
                              overlayShape: RoundSliderOverlayShape( //可继承SliderComponentShape自定义形状
                                overlayRadius: 16, //滑块外圈大小
                              ),
                            ),
                            child: Slider(
                              value: showSeekbarValue,
                              onChanged: (v) {
                                log('$v');
                                setState(() {
                                  gasAmountValueText = formatNum(v, 6);
                                  showSeekbarValue = double.parse(gasAmountValueText);
                                });
                              },
                              min: ChainParams.DEFAULT_DELEGATION_NETWORK_FEE,
                              max: ChainParams.DEFAULT_DELEGATION_NETWORK_FEE * 3,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        IconFont.ic_rabbit,
                        size: 22.0,
                        color: Color(AppColors.COLOR_PRIMARY),
                      ),
                    ],
                  ),
                )
              : Offstage(),
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
        onPressed: _verifyTxData,
        color: Color(AppColors.COLOR_PRIMARY),
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
