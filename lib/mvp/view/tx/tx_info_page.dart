import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/tx_detail_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/tx_info_model.dart';
import 'package:wallet/mvp/contract/tx_info_contract.dart';
import 'package:wallet/mvp/presenter/tx_info_presenter_impl.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 交易详情页面
///
class TxInfoPage extends StatefulWidget {
  String hash;

  TxInfoPage({this.hash});

  @override
  _TxInfoPageState createState() => _TxInfoPageState();
}

class _TxInfoPageState extends State<TxInfoPage> implements TxInfoView {
  TxInfoPresenterImpl mPresenter;

  ScrollController _scrollController = ScrollController();

  List<TxInfoModel> txDetailList = List<TxInfoModel>();

  @override
  void initState() {
    super.initState();
    mPresenter = TxInfoPresenterImpl(this);
    mPresenter.getTx(widget.hash);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "tx.detail"),
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
      body: Container(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: txDetailList.length,
          itemBuilder: (context, index) {
            return TxDetailItem(
              model: txDetailList[index],
              lastOne: index == txDetailList.length - 1,
            );
          },
        ),
      ),
    );
  }

  @override
  void onResponseTxData(Map<String, dynamic> response) {
    log('getTx.Resp = $response');

    List<dynamic> logs = response['logs'];
    var tx = response['tx'];
    if (tx != null && tx.isNotEmpty) {
      var txValue = tx['value'];
      var msgs = txValue['msg'];
      for (int msgIndex = 0; msgIndex < msgs.length; msgIndex++) {
        //循环，可能会有多对多转账交易，在当前app里，只有1个
        var msg = msgs[msgIndex];
        var value = msg['value'];
        var amountList = value['amount'];
        for (int i = 0; i < amountList.length; i++) {
          var amountItem = amountList[i];
          String amountContent = "";
          String denom = amountItem['denom'];
          if (denom == ChainParams.MAIN_TOKEN_DENOM) {
            double amount = double.parse(amountItem['amount']) /
                ChainParams.MAIN_TOKEN_UNIT;
            amountContent =
                '${formatNum(amount, 6)} ${ChainParams.MAIN_TOKEN_SHORT_NAME}';
          } else {
            double amount =
                double.parse(amountItem['amount']) / ChainParams.SUB_TOKEN_UNIT;
            amountContent = '${formatNum(amount, 6)} ${denom.toUpperCase()}';
          }

          txDetailList.add(TxInfoModel(
              icon: IconFont.ic_pay,
              name: FlutterI18n.translate(context, "tx.amount"),
              content: amountContent,
              isCopy: false,
              isSuccess: false));
        }

        var timestamp = response['timestamp'];
        txDetailList.add(TxInfoModel(
            icon: IconFont.ic_trade_time,
            name: FlutterI18n.translate(context, "tx.datetime"),
            content: formatDatetime(parseDatetimeFromChain(timestamp)),
            isCopy: false,
            isSuccess: false));

        String toAddress = value['to_address'];
        txDetailList.add(TxInfoModel(
            icon: IconFont.ic_arrow_down,
            name: FlutterI18n.translate(context, "tx.to_address"),
            content: toAddress,
            isCopy: true,
            isSuccess: false));

        String fromAddress = value['from_address'];
        txDetailList.add(TxInfoModel(
            icon: IconFont.ic_arrow_up,
            name: FlutterI18n.translate(context, "tx.from_address"),
            content: fromAddress,
            isCopy: true,
            isSuccess: false));

        logs.forEach((log) {
          if (log['msg_index'] == msgIndex) {
            bool success = log['success'];
            if (success) {
              txDetailList.add(TxInfoModel(
                  icon: IconFont.ic_trade_status,
                  name: FlutterI18n.translate(context, "tx.status"),
                  content: FlutterI18n.translate(context, "status_successful"),
                  isCopy: false,
                  isSuccess: true));
            } else {
              txDetailList.add(TxInfoModel(
                  icon: IconFont.ic_trade_status,
                  name: FlutterI18n.translate(context, "tx.status"),
                  content:
                      '${FlutterI18n.translate(context, "status_failed")}-$log["log"]',
                  isCopy: false,
                  isSuccess: false));
            }
          }
        });
      }

      var fee = txValue['fee']['amount'][0]['amount'];
      var feeAmount =
          formatNum(double.parse(fee) / ChainParams.MAIN_TOKEN_UNIT, 6);
      txDetailList.add(TxInfoModel(
          icon: IconFont.ic_net_fee1,
          name: FlutterI18n.translate(context, "tx.network_fee"),
          content: feeAmount,
          isCopy: false,
          isSuccess: false));

      var memo = txValue['memo'];
      txDetailList.add(TxInfoModel(
          icon: IconFont.ic_note_write,
          name: FlutterI18n.translate(context, "tx.memo"),
          content: memo,
          isCopy: false,
          isSuccess: false));

      var height = response['height'];
      txDetailList.add(TxInfoModel(
          icon: IconFont.ic_tx_height,
          name: FlutterI18n.translate(context, "tx.height"),
          content: height,
          isCopy: false,
          isSuccess: false));

      var hash = response['txhash'];
      txDetailList.add(TxInfoModel(
          icon: IconFont.ic_hash_tag,
          name: FlutterI18n.translate(context, "tx.hash"),
          content: hash,
          isCopy: true,
          isSuccess: false));
    }

    setState(() {});
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
