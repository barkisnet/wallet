import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/system_utils.dart';

import 'fixed_size_text.dart';

///
/// 底部弹出框
///

class CommonBottomSheet extends StatefulWidget {
  final List<CommonBottomModel> itemList;

  final OnItemClickListener onItemClickListener;

  CommonBottomSheet({Key, key, this.itemList, this.onItemClickListener})
      : assert(itemList != null),
        super(key: key);

  @override
  _CommonBottomSheetState createState() => _CommonBottomSheetState();
}

typedef OnItemClickListener = void Function(int index);

class _CommonBottomSheetState extends State<CommonBottomSheet> {
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
      child: Column(
        children: [
          _buildListView(context),
          _buildCancelView(context),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Container(
      width: SystemUtils.getWidth(context) - 30,
      decoration: BoxDecoration(
        color: Color(AppColors.WHITE),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.itemList.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItemView(context, index);
        },
      ),
    );
  }

  Widget _buildItemView(BuildContext context, index) {
    return Container(
      height: 48.0,
      width: SystemUtils.getWidth(context) - 30,
      child: Column(
        children: [
          Expanded(
            child: RaisedButton(
              onPressed: () {
                if (onItemClickListener != null) {
                  onItemClickListener(index);
                }
              },
              color: Color(AppColors.WHITE),
              highlightColor: Color(AppColors.SP_LINE),
              shape: RoundedRectangleBorder(
                borderRadius: index == 0
                    ? BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0))
                    : index == widget.itemList.length - 1
                    ? BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))
                    : BorderRadius.all(Radius.circular(0.0)),
              ),
              child: Center(
                child: FixedSizeText(
                  widget.itemList[index].name,
                  style: TextStyle(
                      color: widget.itemList[index].itemLabelColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          index == widget.itemList.length - 1
              ? Offstage()
              : Divider(color: Color(AppColors.SP_LINE), height: 0.5),
        ],
      ),
    );
  }

  Widget _buildCancelView(BuildContext context) {
    return Container(
      height: 48.0,
      width: SystemUtils.getWidth(context) - 30,
      margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: RaisedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        color: Color(AppColors.WHITE),
        highlightColor: Color(AppColors.SP_LINE),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Center(
          child: FixedSizeText(
            FlutterI18n.translate(context, "button.cancel"),
            style: TextStyle(
                color: Color(AppColors.GREY_1),
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class CommonBottomModel {
  String name;
  Color itemLabelColor;

  CommonBottomModel({this.name, this.itemLabelColor});
}
