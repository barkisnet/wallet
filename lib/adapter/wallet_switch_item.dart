import 'package:flutter/material.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// Wallet Item
///

class WalletSwitchItem extends StatefulWidget {
  WalletModel wallet;

  WalletSwitchItem({this.wallet});

  @override
  _WalletSwitchItemState createState() => _WalletSwitchItemState();
}

class _WalletSwitchItemState extends State<WalletSwitchItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Color(AppColors.WHITE),
          child: InkWell(
            onTap: () {
              if(!widget.wallet.selected){
                eventBus.fire(WalletChangeListener(address: widget.wallet.address));
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              child: Card(
                elevation: 0.0,
                color: Color(AppColors.WHITE),
                margin: EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  side: BorderSide(
                    width: 1.0,
                    color: Color(widget.wallet.selected
                        ? AppColors.COLOR_PRIMARY
                        : AppColors.GREY_2),
                  ),
                ),
                //设置圆角
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 12.0, top: 16.0, bottom: 10.0),
                      child: FixedSizeText(
                        widget.wallet.name,
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: FixedSizeText(
                        widget.wallet.address,
                        style: TextStyle(
                          color: Color(AppColors.GREY_1),
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, bottom: 16.0, top: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FixedSizeText(
                            formatNum(
                                widget.wallet.balance / ChainParams.MAIN_TOKEN_UNIT,
                                6),
                            style: TextStyle(
                                color: Color(AppColors.COLOR_PRIMARY),
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 3.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: FixedSizeText(
                              ChainParams.MAIN_TOKEN_SHORT_NAME,
                              style: TextStyle(
                                color: Color(AppColors.GREY_1),
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20.0,
          child: Container(
            width: 18.0,
            height: 18.0,
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              IconFont.ic_check_cirle,
              size: 18.0,
              color: Color(widget.wallet.selected
                  ? AppColors.COLOR_PRIMARY
                  : AppColors.GREY_2),
            ),
          ),
        ),
      ],
    );
  }
}
