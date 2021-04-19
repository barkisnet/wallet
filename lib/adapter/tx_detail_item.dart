import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/tx_info_model.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 交易流水 Item
///

class TxDetailItem extends StatefulWidget {
  TxInfoModel model;
  bool lastOne;

  TxDetailItem({this.model, this.lastOne});

  @override
  _TxDetailItemState createState() => _TxDetailItemState();
}

class _TxDetailItemState extends State<TxDetailItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      color: Color(AppColors.WHITE),
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: widget.lastOne ? 20.0 : 0.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      //设置圆角
      child: Container(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.model.icon,
                  color: Color(AppColors.GREY_1),
                ),
                SizedBox(
                  width: 10.0,
                ),
                FixedSizeText(
                  widget.model.name,
                  style: TextStyle(
                      color: Color(AppColors.BLACK),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10.0,),
            Row(
              children: [
                widget.model.isSuccess
                    ? Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                          IconFont.ic_success,
                          size: 18.0,
                          color: Color(AppColors.GREEN),
                        ),
                    )
                    : Offstage(),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: FixedSizeText(
                    widget.model.content,
                    style: TextStyle(
                        color: Color(AppColors.GREY_1),
                    ),
                  ),
                ),
                widget.model.isCopy
                    ? InkWell(
                        onTap: (){
                          Clipboard.setData(ClipboardData(text: widget.model.content));
                          ToastUtils.show(FlutterI18n.translate(context, 'copied'));
                        },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                            IconFont.ic_copy,
                            size: 14.0,
                            color: Color(AppColors.GREY_1),
                          ),
                      ),
                    )
                    : Offstage(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
