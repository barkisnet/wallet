import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 收款 二维码
///

class QRCodePage extends StatefulWidget {
  String walletAddress;

  QRCodePage({this.walletAddress});

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "qrcode.title"),
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
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
      body: ListView(
        children: [
          _buildQrcodeView(context),
        ],
      ),
    );
  }

  Widget _buildQrcodeView(BuildContext context) {
    return Container(
      child: Card(
        elevation: 5.0,
        color: Color(AppColors.WHITE),
        margin: EdgeInsets.all(16.0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //设置圆角
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30.0),
              child: QrImage(
                data: widget.walletAddress,
                size: (SystemUtils.getWidth(context) - 20) / 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 36.0, right: 36, top: 16.0, bottom: 20.0),
              child: FixedSizeText(
                widget.walletAddress == null ? '' : widget.walletAddress,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(AppColors.GREY_1),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: (SystemUtils.getWidth(context) - 32) / 2,
              height: 46.0,
              margin: EdgeInsets.only(bottom: 30.0),
              child: RaisedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.walletAddress));
                  ToastUtils.show(FlutterI18n.translate(context, "copied"));
                },
                color: Color(AppColors.COLOR_PRIMARY),
                highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                child: Center(
                  child: FixedSizeText(
                    FlutterI18n.translate(context, "qrcode.copy_address"),
                    style: TextStyle(
                      color: Color(AppColors.WHITE),
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
