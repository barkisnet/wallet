import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/utils/constants.dart';

///
/// 版本升级dialog
///

class UpdateDialog extends StatefulWidget {
  final key;
  final newVersion;
  final newFeature;
  final Function onClickWhenDownload;
  final Function onClickWhenNotDownload;

  UpdateDialog({
    this.key,
    this.newVersion,
    this.newFeature,
    this.onClickWhenDownload,
    this.onClickWhenNotDownload,
  });

  @override
  State<StatefulWidget> createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  var _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          new Text(
            FlutterI18n.translate(context, "new_version.update_title"),
            style: TextStyle(
              color: Color(AppColors.BLACK),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 6.0,
          ),
          new Text(
            "v${widget.newVersion}",
            style: TextStyle(
              color: Color(AppColors.GREY_1),
              fontSize: 15.0,
            ),
          ),
        ],
      ),
      content: _downloadProgress == 0.0
          ? new Text(
              "${widget.newFeature}",
              style: TextStyle(
                color: Color(AppColors.BLACK),
              ),
            )
          : new LinearProgressIndicator(
              value: _downloadProgress,
            ),
      actions: <Widget>[
        new FlatButton(
          child: new Text(
            FlutterI18n.translate(context, "new_version.update"),
            style: TextStyle(
              color: Color(AppColors.COLOR_PRIMARY),
//              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          color: Color(AppColors.WHITE),
          onPressed: () {
            if (_downloadProgress != 0.0) {
              widget.onClickWhenDownload(FlutterI18n.translate(context, "new_version.downloading"));
              return;
            }
            widget.onClickWhenNotDownload();
//            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text(
            FlutterI18n.translate(context, "button.cancel"),
            style: TextStyle(
              color: Color(AppColors.GREY_1),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  set progress(_progress) {
    setState(() {
      _downloadProgress = _progress;
      if (_downloadProgress == 1) {
        Navigator.of(context).pop();
        _downloadProgress = 0.0;
      }
    });
  }
}
