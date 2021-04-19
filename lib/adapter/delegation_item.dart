import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/delegation_model.dart';
import 'package:wallet/mvp/view/validator/validator_detail_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 委托 Item
///

class DelegationItem extends StatefulWidget {
  DelegationModel delegation;

  DelegationItem({this.delegation});

  @override
  _DelegationItemState createState() => _DelegationItemState();
}

class _DelegationItemState extends State<DelegationItem> {
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
              if (widget.delegation.validator != null) {//防止异步的数据没取回来
                navPush(context, ValidatorDetailPage(validator: widget.delegation.validator));
              } else {
                ToastUtils.show(FlutterI18n.translate(context, 'validator.loading'));//"正在获取验证人信息，请稍后再试"
              }
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
                      widget.delegation.validatorName,
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
                Clipboard.setData(ClipboardData(text: widget.delegation.validatorAddress));
                ToastUtils.show(FlutterI18n.translate(context, 'copied'));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 0.0, bottom: 10.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FixedSizeText(
                        widget.delegation.validatorAddress,
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
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
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
                          FlutterI18n.translate(context, 'delegation.delegated'),
                          style: TextStyle(
                              color: Color(AppColors.GREY_1), fontSize: 12.0),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        FixedSizeText(
                          formatNum(widget.delegation.delegationAmount, 6),
                          style: TextStyle(
                              color: Color(AppColors.BLACK),
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'delegation.reward'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      FixedSizeText(
                        formatNum(widget.delegation.rewardAmount, 6),
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
