import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/validator_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/validator_detail_contract.dart';
import 'package:wallet/mvp/presenter/validator_detail_presenter_impl.dart';
import 'package:wallet/mvp/view/validator/delegation_tx_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 验证人详情页
///

class ValidatorDetailPage extends StatefulWidget {
  ValidatorModel validator;

  ValidatorDetailPage({this.validator});

  @override
  _ValidatorDetailPageState createState() => _ValidatorDetailPageState();
}

class _ValidatorDetailPageState extends State<ValidatorDetailPage> implements ValidatorDetailView {
  ValidatorDetailPresenterImpl mPresenter;
  WalletModel wallet = new WalletModel();

  double availableAmount = 0;
  double myDelegationAmount = 0;
  double myUndelegationAmount = 0;
  double myRewardAmount = 0;

  @override
  void initState() {
    super.initState();
    mPresenter = ValidatorDetailPresenterImpl(this);
    //初始化获取当前钱包信息
    SPUtils.getWalletInfo().then((walletInfo) {
      setState(() {
        wallet = walletInfo;
      });

      //计算自委托
      mPresenter.getSelfDelegationRate(widget.validator.bech32Address, widget.validator.valoperAddress);
      // 计算当前钱包的委托数量
      mPresenter.getDelegation(wallet.address, widget.validator.valoperAddress);
      mPresenter.getUndelegation(wallet.address, widget.validator.valoperAddress);
      mPresenter.getReward(wallet.address, widget.validator.valoperAddress);
      mPresenter.getBalance(wallet.address);
    });

    if (wallet.address != widget.validator.bech32Address) { //当前账户与验证人不相同，则不获取佣金，并隐藏[领取佣金]按钮
      //获取佣金
      mPresenter.getRewardAndCommission(widget.validator.valoperAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'validator.title'),
          style: TextStyle(
            color: Color(AppColors.WHITE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(AppColors.COLOR_PRIMARY),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            icon: Icon(
              IconFont.ic_backarrow,
              size: 20.0,
              color: Color(AppColors.WHITE),
            ),
            onPressed: () {
              navPop(context);
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_question,
              size: 20.0,
              color: Color(AppColors.WHITE),
            ),
            onPressed: () {
              showTipDialog();
            },
          ),
        ],
      ),
      backgroundColor: Color(AppColors.MAIN_COLOR),
      body: Container(
        child: Stack(
          children: [
            Container(
              height: 90.0,
              decoration: BoxDecoration(
                color: Color(AppColors.COLOR_PRIMARY),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
              ),
            ),
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Color(AppColors.WHITE),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                        child: FixedSizeText(widget.validator.validatorName, style: TextStyle(color: Color(AppColors.BLACK), fontSize: 18.0, fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FixedSizeText(FlutterI18n.translate(context, 'validator.operator_address'), style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),),
                            SizedBox(width: 10.0),
                            Expanded(child: FixedSizeText(widget.validator.valoperAddress, style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),)),
                            Material(
                              color: Color(AppColors.WHITE),
                              child: InkWell(
                                onTap: (){
                                  Clipboard.setData(ClipboardData(text: widget.validator.valoperAddress));
                                  ToastUtils.show(FlutterI18n.translate(context, 'copied'));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 8.0),
                                  child: Icon(IconFont.ic_copy, color: Color(AppColors.GREY_1),size: 14.0,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FixedSizeText(FlutterI18n.translate(context, 'validator.self_delegate_address'), style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),),
                            SizedBox(width: 10.0),
                            Expanded(child: FixedSizeText(widget.validator.bech32Address, style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),)),
                            Material(
                              color: Color(AppColors.WHITE),
                              child: InkWell(
                                onTap: (){
                                  Clipboard.setData(ClipboardData(text: widget.validator.bech32Address));
                                  ToastUtils.show(FlutterI18n.translate(context, 'copied'));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 8.0),
                                  child: Icon(IconFont.ic_copy, color: Color(AppColors.GREY_1),size: 14.0,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          color: Color(AppColors.GREY_3),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'delegation.total'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    formatNum(widget.validator.delegationAmount, 6),
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'validator.self_delegation_ratio'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    '${formatNum(widget.validator.selfDelegationRate, 2)}%',
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0,
                                  bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'validator.commission_rate'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    '${formatNum(widget.validator.commissionRate * 100, 2)}%',
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            (wallet.address != widget.validator.bech32Address)
                                ? Offstage()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        bottom: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FixedSizeText(
                                          FlutterI18n.translate(context, "validator.commission"),
                                          style: TextStyle(
                                              color: Color(AppColors.GREY_1),
                                              fontSize: 14.0),
                                        ),
                                        FixedSizeText(
                                          formatNum(
                                              widget.validator.commissionAmount, 6),
                                          style: TextStyle(
                                              color: Color(AppColors.BLACK),
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                            (wallet.address != widget.validator.bech32Address)
                                ? Offstage()
                                : Container(
                                    height: 45.0,
                                    width: SystemUtils.getWidth(context) - 50,
                                    margin: EdgeInsets.only(
                                        left: 25.0, right: 25.0, bottom: 15.0),
                                    child: RaisedButton(
                                      onPressed: widget.validator.commissionAmount > 1/ChainParams.MAIN_TOKEN_UNIT ? () {
                                        navPush(
                                            context,
                                            DelegationTxPage(
                                                type: 'commission',
                                                validatorAddress: widget.validator.valoperAddress,
                                                wallet: wallet,
                                                amount: widget.validator.commissionAmount,
                                                balance: this.availableAmount));
                                      } : null,
                                      color: Color(AppColors.COLOR_PRIMARY),
                                      highlightColor: Color(
                                          AppColors.COLOR_PRIMARY_HIGHLIGHT),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6.0))),
                                      child: Center(
                                        child: FixedSizeText(
                                          FlutterI18n.translate(context, 'validator.withdraw_commission'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Color(AppColors.WHITE),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 15.0),
                        child: FixedSizeText(wallet.name, style: TextStyle(color: Color(AppColors.BLACK), fontSize: 18.0, fontWeight: FontWeight.bold),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FixedSizeText(FlutterI18n.translate(context, "wallet.address"), style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),),
                            SizedBox(width: 10.0),
                            Expanded(child: FixedSizeText(wallet.address, style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0),)),
                            Material(
                              color: Color(AppColors.WHITE),
                              child: InkWell(
                                onTap: (){
                                  Clipboard.setData(ClipboardData(text: wallet.address));
                                  ToastUtils.show(FlutterI18n.translate(context, 'copied'));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 8.0),
                                  child: Icon(IconFont.ic_copy, color: Color(AppColors.GREY_1),size: 14.0,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          color: Color(AppColors.GREY_3),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'delegation.available'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    formatNum(availableAmount, 6),
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'delegation.delegated'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    formatNum(myDelegationAmount, 6),
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'delegation.undelegating'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    formatNum(myUndelegationAmount, 6),
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FixedSizeText(
                                    FlutterI18n.translate(context, 'delegation.reward'),
                                    style: TextStyle(
                                        color: Color(AppColors.GREY_1), fontSize: 14.0),
                                  ),
                                  FixedSizeText(
                                    formatNum(myRewardAmount, 6),
                                    style: TextStyle(
                                        color: Color(AppColors.BLACK),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 45.0,
//                                  width: SystemUtils.getWidth(context) - 50,
                                    child: RaisedButton(
                                      onPressed: availableAmount > 1/ChainParams.MAIN_TOKEN_UNIT ? (){
                                              navPush(
                                                  context,
                                                  DelegationTxPage(
                                                      type: 'delegation',
                                                      validatorAddress: widget
                                                          .validator
                                                          .valoperAddress,
                                                      wallet: wallet,
                                                      amount: this
                                                          .availableAmount));
                                            } : null,
                                      color: Color(AppColors.COLOR_PRIMARY),
                                      disabledColor: Color(AppColors.GREY_2),
                                      highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(6.0))),
                                      child: Center(
                                        child: FixedSizeText(
                                          FlutterI18n.translate(context, 'delegation.delegate'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 45.0,
//                                  width: SystemUtils.getWidth(context) - 50,
                                    child: RaisedButton(
                                      onPressed: myDelegationAmount > 1/ChainParams.MAIN_TOKEN_UNIT ? (){
                                              navPush(
                                                  context,
                                                  DelegationTxPage(
                                                      type: 'undelegation',
                                                      validatorAddress: widget
                                                          .validator
                                                          .valoperAddress,
                                                      wallet: wallet,
                                                      amount: this
                                                          .myDelegationAmount,
                                                  balance: this.availableAmount));
                                            } : null,
                                      color: Color(AppColors.COLOR_PRIMARY),
                                      disabledColor: Color(AppColors.GREY_2),
                                      highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(6.0))),
                                      child: Center(
                                        child: FixedSizeText(
                                          FlutterI18n.translate(context, 'delegation.undelegate'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 45.0,
                                    child: RaisedButton(
                                      onPressed: myRewardAmount > 1/ChainParams.MAIN_TOKEN_UNIT ? (){
                                              navPush(
                                                  context,
                                                  DelegationTxPage(
                                                      type: 'reward',
                                                      validatorAddress: widget
                                                          .validator
                                                          .valoperAddress,
                                                      wallet: wallet,
                                                      amount:
                                                          this.myRewardAmount,
                                                      balance: this.availableAmount));
                                            } : null,
                                      color: Color(AppColors.COLOR_PRIMARY),
                                      disabledColor: Color(AppColors.GREY_2),
                                      highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(6.0))),
                                      child: Center(
                                        child: FixedSizeText(
                                          FlutterI18n.translate(context, 'validator.withdraw_reward'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showTipDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: FixedSizeText(FlutterI18n.translate(context, 'validator.title_delegation_rule'),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
            content: SingleChildScrollView(
              child: FixedSizeText(
                FlutterI18n.translate(context, 'validator.tip_delegation_rule_content'),
                style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0, height: 1.5),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Color(AppColors.COLOR_PRIMARY),
                highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                child: FixedSizeText(
                  FlutterI18n.translate(context, 'button.cancel'),
                  style: TextStyle(color: Color(AppColors.WHITE)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void onResponseRewardAndCommissionData(Map<String, dynamic> response) {
    log('ValidatorDetial RewardAndCommission.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      double commissionAmount = 0;

      var commission = result['val_commission'];
      if(commission != null) {
        commission.forEach((commission){
          if(commission['denom'] == ChainParams.MAIN_TOKEN_DENOM){
            commissionAmount = double.parse(commission['amount']) / ChainParams.MAIN_TOKEN_UNIT;
            return;
          }
        });
      }

      setState(() {
        widget.validator.commissionAmount = commissionAmount;
      });
    }
  }

  @override
  void onResponseSelfDelegationRateData(Map<String, dynamic> response) {
    log('ValidatorDetial SelfDelegationRate.Resp = $response');
    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      //获取委托数量
      double delegationAmount = double.parse(result['shares']);

      setState(() {
        // 计算自抵押比例
        widget.validator.selfDelegationRate = (delegationAmount * 100) /
            (widget.validator.delegationAmount * ChainParams.MAIN_TOKEN_UNIT);
      });
    }
  }

  @override
  void onResponseDelegationData(Map<String, dynamic> response) {
    log('ValidatorDetial Delegation.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      var delegatorAddress = result['delegator_address'];
      var validatorAddress = result['validator_address'];

      //获取委托数量
      double delegationAmount = double.parse(result['shares']);

      setState(() {
        // 计算公式=(验证人的tokens/验证人的delegator_shares)*委托人的shares，
        // 目前不需要这么复杂的算法，直接显示shares
        // myDelegationAmount = (delegationAmount * widget.validator.tokens) /
        // (widget.validator.delegatorShares * ChainParams.MAIN_TOKEN_UNIT);

        myDelegationAmount = delegationAmount / ChainParams.MAIN_TOKEN_UNIT;
      });
    }
  }

  @override
  void onResponseUndelegationData(Map<String, dynamic> response) {
    log('ValidatorDetial Undelegation.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      var delegatorAddress = result['delegator_address'];
      var validatorAddress = result['validator_address'];

      double undelegationAmount = 0;
      result['entries'].forEach((entry){
        var balance = double.parse(entry['balance']);
        undelegationAmount += balance;
      });

      setState(() {
        myUndelegationAmount = undelegationAmount / ChainParams.MAIN_TOKEN_UNIT;
      });
    }
  }

  @override
  void onResponseRewardData(Map<String, dynamic> response) {
    log('ValidatorDetial Reward.Resp = $response');

    double rewardAmount = 0;
    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((reward){
        if(reward['denom'] == ChainParams.MAIN_TOKEN_DENOM) {
          var balance = double.parse(reward['amount']);
          rewardAmount += balance;
        }
      });

      setState(() {
        myRewardAmount = rewardAmount / ChainParams.MAIN_TOKEN_UNIT;
      });
    }
  }

  @override
  void onResponseBalanceData(Map<String, dynamic> response) {

    log('ValidatorDetail Balance.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((token) {
        if (token['denom'] == ChainParams.MAIN_TOKEN_DENOM) {
          setState(() {
            availableAmount =
                double.parse(token['amount']) / ChainParams.MAIN_TOKEN_UNIT;
          });
          return;
        }
      });
    }
  }

  @override
  void dismissLoading() {
    // TODO: implement dismissLoading
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void showMessage(String msg) {
    // TODO: implement showMessage
  }
}
