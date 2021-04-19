import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/model/record_delegation_model.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 收益&佣金流水 Item
///

class RecordRewardCommissionItem extends StatefulWidget {
  RecordDelegationModel model;

  RecordRewardCommissionItem({this.model});

  @override
  _RecordRewardCommissionItemState createState() => _RecordRewardCommissionItemState();
}

class _RecordRewardCommissionItemState extends State<RecordRewardCommissionItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
//              Padding(
//                padding: const EdgeInsets.all(16.0),
//                child: FixedSizeText(widget.model.type, style: TextStyle(color: Color(AppColors.BLACK), fontSize: 16.0, fontWeight: FontWeight.bold),),
//              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 15.0, top: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: SystemUtils.getWidth(context) - (Platform.isIOS ? 170 : 150),
                            child: FixedSizeText(widget.model.validatorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(AppColors.BLACK), fontSize: 15.0, fontWeight: FontWeight.bold),),
                          ),
                          FixedSizeText(formatDatetime(widget.model.datetime), style: TextStyle(color: Color(AppColors.GREY_2), fontSize: 12.0, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 15.0, top: 15.0),
                          child: FixedSizeText(widget.model.shortValidatorAddress, style: TextStyle(color: Color(AppColors.GREY_2), fontSize: 12.0, fontWeight: FontWeight.bold),),
                        ),
                        Container(
                          height: 16.0,
                          margin: EdgeInsets.only(right: 15.0, top: 15.0),
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          decoration: BoxDecoration(
                            color: Color(AppColors.GREEN),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Center(
                            child: FixedSizeText(
                              FlutterI18n.translate(context, 'status_successful'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 11.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 15.0, top: 15.0, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FixedSizeText(widget.model.typeLabel, style: TextStyle(color: Color(AppColors.GREY_2), fontSize: 12.0),),
                          FixedSizeText('${widget.model.amount}', style: TextStyle(color: Color(AppColors.BLACK), fontSize: 12.0, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider(color: Color(AppColors.SP_LINE_2), height: 1.0,),
          ),
        ],
      ),
    );
  }
}
