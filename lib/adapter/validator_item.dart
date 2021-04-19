import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/validator_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/validator/validator_detail_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 验证人 Item
///

class ValidatorItem extends StatefulWidget {
  ValidatorModel validator;
  WalletModel wallet;
  String validatorStatus;

  ValidatorItem({this.validator, this.wallet, this.validatorStatus});

  @override
  _ValidatorItemState createState() => _ValidatorItemState();
}

class _ValidatorItemState extends State<ValidatorItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: (){
              navPush(context, ValidatorDetailPage(validator: widget.validator));
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 12.0, top: 16.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FixedSizeText(
                      widget.validator.validatorName,
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(IconFont.ic_arrowone, color: Color(AppColors.GREY_1), size: 24.0,),
                ],
              ),
            ),
          ),
          Material(
            color: Color(AppColors.WHITE),
            child: InkWell(
              onTap: (){
                Clipboard.setData(ClipboardData(text: widget.validator.valoperAddress));
                ToastUtils.show(FlutterI18n.translate(context, 'copied'));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, top: 0.0, bottom: 10.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FixedSizeText(
                        widget.validator.valoperAddress,
                        style: TextStyle(
                          color: Color(AppColors.GREY_1),
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6.0,
                    ),
                    Icon(
                      IconFont.ic_copy,
                      color: Color(AppColors.GREY_2),
                      size: 14.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(AppColors.GREY_3),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 10.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
//                    width: (SystemUtils.getWidth(context) - 52) / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FixedSizeText(
                          FlutterI18n.translate(context, 'delegation.total'),
                          style: TextStyle(
                              color: Color(AppColors.GREY_1), fontSize: 12.0),
                        ),
                        SizedBox(
                          height: 12.0,
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
                  widget.validatorStatus == 'active' ? Offstage() : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'validator.candidate_node'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      FixedSizeText(
                        widget.validator.jailed ? FlutterI18n.translate(context, 'no') : FlutterI18n.translate(context, 'yes'),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'validator.commission_rate'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      FixedSizeText(
                        '${formatNum(widget.validator.commissionRate * 100, 2)}%',
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
