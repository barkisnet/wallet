import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sacco/models/transaction_result.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/contact/contact_page.dart';
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
/// 转账
///

class TxSendPage extends StatefulWidget {
  WalletModel wallet;
  String denom;
  double availableAmount;
  String recipientAddress;

  TxSendPage(
      {this.wallet, this.denom, this.availableAmount, this.recipientAddress});

  @override
  _TxSendPageState createState() => _TxSendPageState();
}

class _TxSendPageState extends State<TxSendPage> {
  TextEditingController _recipientAddressTextEditingController = TextEditingController();
  TextEditingController _sendAmountTextEditingController = TextEditingController();
  TextEditingController _memoTextEditingController = TextEditingController(text: '');

  FocusNode _recipientAddressFocusNode = FocusNode();
  FocusNode _sendAmountFocusNode = FocusNode();
  FocusNode _memoFocusNode = FocusNode();
  FocusNode _netfeeFocusNode = FocusNode();

  String gasAmountValueText = ChainParams.DEFAULT_TX_NETWORK_FEE.toString();

  double showSeekbarValue = ChainParams.DEFAULT_TX_NETWORK_FEE;

  bool _isCustomNetFee = false;

  bool _sending = false;

  void _verifySendTxData() {
    String recipientAddress = _recipientAddressTextEditingController.text;
    String sendAmount = _sendAmountTextEditingController.text;
    String memo = _memoTextEditingController.text;

    if (recipientAddress.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "tx.to_address_empty"));
      _recipientAddressFocusNode.requestFocus();
      return;
    }
    if (!isValidAddress(recipientAddress)) {
      ToastUtils.show(FlutterI18n.translate(context, "tx.to_address_invalid"));
      _recipientAddressFocusNode.requestFocus();
      return;
    }
    if (sendAmount.isEmpty) {
      ToastUtils.show(FlutterI18n.translate(context, "tx.amount_empty"));
      _sendAmountFocusNode.requestFocus();
      return;
    }
    // 手续费不能低于设定的默认值，不能高于3倍
    if (double.parse(gasAmountValueText) < ChainParams.DEFAULT_TX_NETWORK_FEE ||
        double.parse(gasAmountValueText) > ChainParams.DEFAULT_TX_NETWORK_FEE * 3) {
      ToastUtils.show(FlutterI18n.translate(context, "tx.network_fee_hint",
          translationParams: {
            "min": ChainParams.DEFAULT_TX_NETWORK_FEE.toStringAsFixed(3),
            "max": (ChainParams.DEFAULT_TX_NETWORK_FEE * 3).toStringAsFixed(3)
          }));
      _netfeeFocusNode.requestFocus();
      return;
    }
    if (widget.availableAmount < double.parse(sendAmount) + double.parse(gasAmountValueText)) {
      ToastUtils.show(FlutterI18n.translate(context, "tx.balance_insufficient"));
      _sendAmountFocusNode.requestFocus();
      return;
    }

    ///隐藏键盘
    FocusScope.of(context).requestFocus(FocusNode());

    WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, _doSendTx);
  }

  void _doSendTx(BuildContext context) {
    setState(() {
      _sending = true;
    });

    String recipientAddress = _recipientAddressTextEditingController.text.trim();
    String sendAmount = _sendAmountTextEditingController.text.trim();
    String memo = _memoTextEditingController.text.trim();
    Future<TransactionResult> f = TxService.send(
        widget.denom,
        widget.wallet.mnemonic,
        recipientAddress,
        double.parse(sendAmount),
        double.parse(gasAmountValueText),
        memo);

    f.then((tr) {
      setState(() {
        _sending = false;
      });
      if (tr.success) {//transfer_success
        ToastUtils.show(FlutterI18n.translate(context, "transfer_success"));
        navPop(context);
      } else {
        ToastUtils.show(FlutterI18n.translate(context, "transfer_fail",
            translationParams: {
              "error": tr.error.errorMessage
            }));
      }
    });
  }

  Future scan() async {
    var result = await BarcodeScanner.scan();
    log('扫一扫结果：${result.rawContent}');
    _recipientAddressTextEditingController.text =
        result.rawContent == null ? '' : result.rawContent;
  }

  void _checkPersmissions() async {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    statusFuture.then((status) {
      if (status != PermissionStatus.granted) {
        requestPermission(PermissionGroup.camera);
      } else {
        scan();
      }
    });
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    log('permissionRequestResult = $permissionRequestResult');

    if (permissionRequestResult[permission] != PermissionStatus.granted) {
      ToastUtils.show(FlutterI18n.translate(context, "camera_permission"));
    } else {
      scan();
    }
  }

  @override
  void initState() {
    super.initState();
    log('widget.recipientAddress = ${widget.recipientAddress}');
    _recipientAddressTextEditingController.text =
        widget.recipientAddress == null ? '' : widget.recipientAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "tx.transfer"),
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_scan,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              _checkPersmissions();
            },
          ),
        ],
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
                FlutterI18n.translate(context, "tx.sending"),
                style: TextStyle(
                    color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
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
              SizedBox(height: 15.0),
              _buildReceiveAddressView(context),
              SizedBox(height: 10.0),
              _buildSendNumberView(context),
              SizedBox(height: 10.0),
              _buildMemoView(context),
              SizedBox(height: 10.0),
              _buildNetworkFeeView(context),
              SizedBox(height: 30.0),
              _buildButtonView(context),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  ///收款地址
  Widget _buildReceiveAddressView(BuildContext context) {
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
                IconFont.ic_tx_address,
                size: 16.0,
                color: Color(AppColors.GREY_1),
              ),
              SizedBox(
                width: 10.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "tx.to_address"),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _recipientAddressFocusNode,
                    controller: _recipientAddressTextEditingController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, "tx.to_address_hint"),
                      hintStyle:
                      TextStyle(color: Color(AppColors.GREY_2), fontSize: 14.0),
                      contentPadding: EdgeInsets.only(
                        left: 15.0,
                        right: 0.0,
                        top: 10.0,
                        bottom: 10.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => ContactPage(option: 2,)))
                        .then((contact) {
                          log('value = $contact');

                          if(contact != null) {
                            setState(() {
                                _recipientAddressTextEditingController.text = contact.address;
                                _memoTextEditingController.text = contact.memo;
                            });
                          }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      IconFont.ic_contact_book,
                      size: 16.0,
                      color: Color(AppColors.GREY_1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///付款数量
  Widget _buildSendNumberView(BuildContext context) {
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
                FlutterI18n.translate(context, "tx.amount"),//'付款数量'
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
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalNumberTextInputFormatter(digit: 6)
              ],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "tx.amount_hint"),
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
              FlutterI18n.translate(context, "tx.amount_tips", translationParams: {"amount": formatNum(widget.availableAmount, 6),
              "unit": (widget.denom == ChainParams.MAIN_TOKEN_DENOM ? ChainParams.MAIN_TOKEN_SHORT_NAME : widget.denom.toUpperCase())}),
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

  ///备注/标签/Tag
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
                FlutterI18n.translate(context, "tx.memo"), //'备注/标签/Tag'
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
                hintText: FlutterI18n.translate(context, "tx.memo_hint"),//请输入交易所/收款方要求的[备注/标签/Tag]
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
              FlutterI18n.translate(context, "tx.memo_tips"),//备注的最大长度为50个字（选填）
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
  Widget _buildNetworkFeeView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding:
          EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 15.0),
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
                    FlutterI18n.translate(context, "tx.network_fee"),//'网络费用'
                    style: TextStyle(
                        color: Color(AppColors.BLACK), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Material(
                    color: Color(AppColors.WHITE),
                    child: InkWell(
                      onTap: (){
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
                    FlutterI18n.translate(context, "tx.network_custom_fee"),//'自定义网络费用'
                    style: TextStyle(
                        color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5.0),
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
              inputFormatters: [
                DecimalNumberTextInputFormatter(digit: 6)
              ],
              maxLines: 1,
              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 14.0),
              onChanged: (val) {
                setState(() {
                  log('textField.text = $val');
                  gasAmountValueText = val;
                  if(val.isEmpty){
                    showSeekbarValue = ChainParams.DEFAULT_TX_NETWORK_FEE;
                  } else {
                    if(val != '0.00' && val != '0.0' && val != '0.' && val != '0'){
                      if(double.parse(val) < ChainParams.DEFAULT_TX_NETWORK_FEE){
                        showSeekbarValue = ChainParams.DEFAULT_TX_NETWORK_FEE;
                      } else if(double.parse(val) > ChainParams.DEFAULT_TX_NETWORK_FEE * 3){
                        showSeekbarValue = ChainParams.DEFAULT_TX_NETWORK_FEE * 3;
                      } else {
                        showSeekbarValue = double.parse(gasAmountValueText);
                      }
                    } else {
                      showSeekbarValue = ChainParams.DEFAULT_TX_NETWORK_FEE;
                    }
                  }
                });
              },
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(context, "tx.network_fee_hint",
                    translationParams: {
                      "min": ChainParams.DEFAULT_TX_NETWORK_FEE.toStringAsFixed(3),
                      "max": (ChainParams.DEFAULT_TX_NETWORK_FEE * 3).toStringAsFixed(3)
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
          _isCustomNetFee ? Padding(
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
                          trackShape: RoundSliderTrackShape(radius: 6),//进度条形状,这边自定义两头显示圆角
                          thumbColor: Color(AppColors.COLOR_PRIMARY), //滑块颜色
                          thumbShape: RoundSliderThumbShape(//可继承SliderComponentShape自定义形状
                            disabledThumbRadius: 6, //禁用是滑块大小
                            enabledThumbRadius: 6, //滑块大小
                          ),
                          overlayShape: RoundSliderOverlayShape(//可继承SliderComponentShape自定义形状
                            overlayRadius: 16, //滑块外圈大小
                          ),
                        ),
                        child: Slider(
                          value: showSeekbarValue,
                          onChanged: (v){
                            log('$v');
                            setState(() {
                              gasAmountValueText = formatNum(v, 6);
                              showSeekbarValue = double.parse(gasAmountValueText);
                            });
                          },
                          min: ChainParams.DEFAULT_TX_NETWORK_FEE,
                          max: ChainParams.DEFAULT_TX_NETWORK_FEE * 3,
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
          ) : Offstage(),
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
        onPressed: _verifySendTxData,
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
