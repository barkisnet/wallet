import 'package:flutter/material.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/asset_tx_model.dart';
import 'package:wallet/mvp/view/tx/tx_info_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/string_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 资产交易 Item
///

class AssetTxItem extends StatefulWidget {
  AssetTxModel model;

  AssetTxItem({this.model});

  @override
  _AssetTxItemState createState() => _AssetTxItemState();
}

class _AssetTxItemState extends State<AssetTxItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: (){
          navPush(context, TxInfoPage(hash: widget.model.hash));
        },
        child: Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        widget.model.isOut
                            ? IconFont.ic_arrow_up
                            : IconFont.ic_arrow_down,
                        color: widget.model.isOut
                            ? Color(AppColors.RED)
                            : Color(AppColors.BLUE),
                        size: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FixedSizeText(
                              formatShortAddress(widget.model.address),
                              style: TextStyle(
                                color: Color(AppColors.BLACK),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            FixedSizeText(
                              formatDatetime(widget.model.datetime),
                              style: TextStyle(
                                color: Color(AppColors.GREY_2),
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  FixedSizeText(
                    widget.model.isOut
                        ? '- ${widget.model.amount}'
                        : '+ ${widget.model.amount}',
                    style: TextStyle(
                      color: widget.model.isOut
                          ? Color(AppColors.RED)
                          : Color(AppColors.BLUE),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Divider(
                  height: 1.0,
                  color: Color(AppColors.SP_LINE_2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
