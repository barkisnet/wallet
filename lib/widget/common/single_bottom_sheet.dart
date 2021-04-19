import 'package:flutter/material.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/system_utils.dart';

import 'fixed_size_text.dart';

///
/// 简单的底部弹框
///

class SingleBottomSheet extends StatefulWidget {
  final List<SingleBottomModel> itemList;

  final OnItemClickListener onItemClickListener;

  SingleBottomSheet({Key, key, this.itemList, this.onItemClickListener})
      : assert(itemList != null),
        super(key: key);

  @override
  _SingleBottomSheetState createState() => _SingleBottomSheetState();
}

typedef OnItemClickListener = void Function(int index);

class _SingleBottomSheetState extends State<SingleBottomSheet> {
  OnItemClickListener onItemClickListener;

  @override
  void initState() {
    super.initState();
    onItemClickListener = widget.onItemClickListener;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          child: _buildContainer(context),
        ),
      ],
    );
  }

  Widget _buildContainer(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context),
      padding: EdgeInsets.only(top: 20.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: Color(AppColors.WHITE),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Material(
              color: Color(AppColors.WHITE),
              child: InkWell(
                onTap: () {
                  if (onItemClickListener != null) {
                    onItemClickListener(0);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          widget.itemList[0].iconData,
                          size: 56,
                          color: widget.itemList[0].iconColor,
                        ),
                      ),
                      FixedSizeText(
                        widget.itemList[0].name,
                        style: TextStyle(
                            color: Color(AppColors.GREY_1),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              color: Color(AppColors.WHITE),
              child: InkWell(
                onTap: () {
                  if (onItemClickListener != null) {
                    onItemClickListener(1);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          widget.itemList[1].iconData,
                          size: 56,
                          color: widget.itemList[1].iconColor,
                        ),
                      ),
                      FixedSizeText(
                        widget.itemList[1].name,
                        style: TextStyle(
                            color: Color(AppColors.GREY_1),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
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

class SingleBottomModel {
  String name;
  IconData iconData;
  Color iconColor;

  SingleBottomModel({this.name, this.iconData, this.iconColor});
}
