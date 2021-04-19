import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 加载网页
///

class WebviewPage extends StatefulWidget {
  String url;
  String titleText;

  WebviewPage({this.url, this.titleText});

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: FixedSizeText(
          widget.titleText,
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(AppColors.WHITE),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
      url: widget.url,
      withZoom: true,
      withLocalStorage: true,
      displayZoomControls: true,
      supportMultipleWindows: true,
      useWideViewPort: true,
      hidden: true,
      initialChild: Container(
        color: Color(AppColors.WHITE),
        child: Center(
          child: FixedSizeText(
            FlutterI18n.translate(context, 'loading'),
            style: TextStyle(
              color: Color(AppColors.GREY_1),
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
