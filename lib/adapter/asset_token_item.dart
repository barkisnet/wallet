import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/token_item_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/asset/asset_sub_token_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// SubToken数据Item
///

class AssetSubTokenItem extends StatefulWidget {
  WalletModel wallet;
  TokenItemModel tokenItem;

  AssetSubTokenItem({this.wallet, this.tokenItem});

  @override
  _AssetSubTokenItemState createState() => _AssetSubTokenItemState();
}

class _AssetSubTokenItemState extends State<AssetSubTokenItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navPush(
            context,
            AssetSubTokenPage(
              wallet: widget.wallet,
              tokenItem: widget.tokenItem,
            ));
      },
      child: Container(
        child: Card(
          elevation: 0.0,
          color: Color(AppColors.MAIN_COLOR),
          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          //设置圆角
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 12.0, top: 16.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FixedSizeText(
                        widget.tokenItem.name.toUpperCase(),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      IconFont.ic_arrowone,
                      color: Color(AppColors.GREY_1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 12.0, bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                        width: (SystemUtils.getWidth(context) - 52) / 2,
                        child: FixedSizeText(
                          FlutterI18n.translate(context, "delegation.available"),
                          style: TextStyle(
                              color: Color(AppColors.GREY_1), fontSize: 12.0),
                        )),
                    FixedSizeText(
                      formatNum(widget.tokenItem.amount, 4),
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
