import 'package:flutter/material.dart';
import 'package:wallet/utils/constants.dart';

import 'fixed_size_text.dart';

///
/// 设置页面的item
///

class SettingItemWidget extends StatefulWidget {
  IconData iconData;
  String title;
  String subTitle;
  bool isVersion;
  OnItemClickListener onItemClick;

  SettingItemWidget(
      {Key key,
      this.iconData,
      this.title,
      this.subTitle,
      this.isVersion = false,
      this.onItemClick})
      : super(key: key);

  @override
  _SettingItemWidgetState createState() => _SettingItemWidgetState();
}

typedef OnItemClickListener = void Function();

class _SettingItemWidgetState extends State<SettingItemWidget> {
  OnItemClickListener onItemClick;

  @override
  void initState() {
    super.initState();
    onItemClick = widget.onItemClick;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (onItemClick != null) {
            onItemClick();
          }
        },
        child: Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 12.0, bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    widget.iconData,
                    size: 16.0,
                    color: Color(AppColors.GREY_1),
                  ),
                  SizedBox(width: 15.0),
                  FixedSizeText(
                    widget.title,
                    style: TextStyle(
                      color: Color(AppColors.BLACK),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FixedSizeText(
                    widget.subTitle == null ? '' : widget.subTitle,
                    style: TextStyle(
                      color: widget.isVersion
                          ? Color(AppColors.RED)
                          : Color(AppColors.BLACK),
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Icon(Icons.keyboard_arrow_right,
                      color: Color(AppColors.GREY_2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
