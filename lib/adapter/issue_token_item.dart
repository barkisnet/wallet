import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/model/issue_token_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/issue/mint_token_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

class IssueTokenItem extends StatefulWidget {
  WalletModel wallet;
  IssueTokenModel token;

  bool isLastone;

  IssueTokenItem({this.wallet, this.token, this.isLastone});

  @override
  _IssueTokenItemState createState() => _IssueTokenItemState();
}

class _IssueTokenItemState extends State<IssueTokenItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0.0,
        color: Color(AppColors.WHITE),
        margin: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 10.0,
            bottom: widget.isLastone ? 20.0 : 0.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //设置圆角
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 10.0),
              child: FixedSizeText(
                widget.token.name,
                style: TextStyle(
                    color: Color(AppColors.BLACK),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: SystemUtils.getWidth(context) - 32,
              margin: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 5.0, bottom: 2.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(AppColors.MAIN_COLOR),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: FixedSizeText(
                widget.token.desc,
                style: TextStyle(
                    color: Color(AppColors.GREY_1), fontSize: 13.0, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.only(left: 16.0, right: 16.0, top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'issue.label_total_supply'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1),
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5.0),
                      FixedSizeText(
                        formatNum(widget.token.total / ChainParams.SUB_TOKEN_UNIT, 6),
                        style: TextStyle(
                            color: Color(AppColors.COLOR_PRIMARY), fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  widget.token.mintable
                      ? Container(
                          height: 24.0,
                          width: 60.0,
                          child: RaisedButton(
                            onPressed: () {
                              navPush(context, MintTokenPage(widget.wallet, widget.token));
                            },
                            color: Color(AppColors.COLOR_PRIMARY),
                            highlightColor:
                                Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6.0))),
                            child: Center(
                              child: FixedSizeText(
                                FlutterI18n.translate(
                                    context, "issue.label_mint"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 24.0,
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          decoration: BoxDecoration(
                            color: Color(AppColors.MAIN_COLOR),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          child: Center(
                            child: FixedSizeText(
                              FlutterI18n.translate(context, 'issue.label_nonmintable'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 11.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
