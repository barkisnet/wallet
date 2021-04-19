import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/model/asset_detail_model.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 资产明细
///

class AssetDetailGridItem extends StatefulWidget {
  AssetDetailModel model;

  AssetDetailGridItem({this.model});

  @override
  _AssetDetailGridItemState createState() => _AssetDetailGridItemState();
}

class _AssetDetailGridItemState extends State<AssetDetailGridItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0.0,
        color: Color(AppColors.WHITE),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6.0))),
        //设置圆角
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 6.0, top: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    widget.model.icon,
                    size: 30.0,
                    color: Color(widget.model.iconColor),
                  ),
                  SizedBox(width: 10.0,),
                  Expanded(
                    child: FixedSizeText(
                      FlutterI18n.translate(context, widget.model.name),
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 12.0, bottom: 16.0),
              child: FixedSizeText(
                widget.model.amount == null
                    ? '0.0000'
                    : widget.model.amount,
                style: TextStyle(
                    color: Color(AppColors.BLACK),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

