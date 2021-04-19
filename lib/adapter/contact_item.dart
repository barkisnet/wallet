import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/contact_model.dart';
import 'package:wallet/mvp/view/qr/qr_code_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/common_bottom_sheet.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 联系人 Item
///

class ContactItem extends StatefulWidget {
  ContactModel contact;
  int option;//option=1时，代表当前页面是转账页面进入，处于选择联系人的状态；option=2时，代表是普通的编辑状态
  bool isLastone;

  ContactItem({this.contact, this.option, this.isLastone});

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.option == 1
          ? null
          : () {
              eventBus
                  .fire(ContactSelectedItem(contact: widget.contact));
            },
      child: Container(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      IconFont.ic_person,
                      size: 16.0,
                      color: Color(AppColors.GREY_1),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    FixedSizeText(
                      widget.contact.name,
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 5.0, bottom: 2.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(AppColors.MAIN_COLOR),
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: InkWell(
                  onTap: () {
                    navPush(context,
                        QRCodePage(walletAddress: widget.contact.address));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: FixedSizeText(
                        widget.contact.address,
                        style: TextStyle(
                            color: Color(AppColors.BLACK), fontSize: 14.0),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          IconFont.ic_qr_code,
                          color: Color(AppColors.GREY_1),
                          size: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 26.0, right: 6.0, top: 5.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FixedSizeText(
                        widget.contact.memo,
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 14.0),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showContactEditDialog(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          IconFont.ic_edit,
                          color: Color(AppColors.COLOR_PRIMARY),
                          size: 18.0,
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
    );
  }

  void showContactEditDialog(BuildContext context) {
    showDialog(
        barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
        context: context,
        builder: (BuildContext context) {
          var list = List<CommonBottomModel>();
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "contact.modify"), itemLabelColor: Color(AppColors.COLOR_PRIMARY)));
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "contact.delete"), itemLabelColor: Color(AppColors.RED)));
          return CommonBottomSheet(
            itemList: list,
            onItemClickListener: (index) async {
              Navigator.of(context).pop();
              switch (index) {
                case 0:
                  showModifyContactDialog(context);
                  break;
                case 1:
                  showDeleteContactDialog(context);
                  break;
              }
            },
          );
        });
  }

  ///修改联系人
  void showModifyContactDialog(BuildContext context) {
    TextEditingController _nameTextEditingController = TextEditingController(text: widget.contact.name);
    TextEditingController _memoTextEditingController = TextEditingController(text: widget.contact.memo);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
//            title: new Text("title"),
            contentPadding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 16.0),
            content: Container(
              height: 268.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconFont.ic_person,
                        size: 16.0,
                        color: Color(AppColors.GREY_1),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FixedSizeText(
                        FlutterI18n.translate(context, "contact.name"),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Material(
                    color: Color(AppColors.MAIN_COLOR),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: TextField(
                      controller: _nameTextEditingController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20)//限制长度
                      ],
                      maxLines: 1,
                      style: TextStyle(
                          color: Color(AppColors.BLACK), fontSize: 14.0),
                      onChanged: (val) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: FlutterI18n.translate(context, "contact.name_hint"),//'请输入联系人名称',
                        hintStyle: TextStyle(
                            color: Color(AppColors.GREY_2), fontSize: 14.0),
                        contentPadding: EdgeInsets.only(
                          left: 15.0,
                          right: 10.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                    ),
                    child: FixedSizeText(
                      FlutterI18n.translate(context, "contact.name_limit"),
                      style: TextStyle(
                        color: Color(AppColors.GREY_2),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    children: [
                      Icon(
                        IconFont.ic_note_write,
                        size: 16.0,
                        color: Color(AppColors.GREY_1),
                      ),
                      SizedBox(width: 10.0),
                      FixedSizeText(
                        FlutterI18n.translate(context, "contact.remark"),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Material(
                    color: Color(AppColors.MAIN_COLOR),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: TextField(
                      controller: _memoTextEditingController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      maxLength: 50,
                      style: TextStyle(
                          color: Color(AppColors.BLACK), fontSize: 14.0),
                      onChanged: (val) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: FlutterI18n.translate(context, "contact.remark_hint"),//'请输入备注',
                        hintStyle: TextStyle(
                            color: Color(AppColors.GREY_2), fontSize: 14.0),
                        contentPadding: EdgeInsets.only(
                          left: 15.0,
                          right: 10.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                    ),
                    child: FixedSizeText(
                      FlutterI18n.translate(context, "contact.remark_tips"),
                      style: TextStyle(
                        color: Color(AppColors.GREY_2),
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.cancel"),
                  style: TextStyle(
                      color: Color(AppColors.GREY_1),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              FlatButton(
                onPressed: () {
                  String contactName = _nameTextEditingController.text.trim();
                  String memo = _memoTextEditingController.text.trim();
                  if (contactName.isEmpty) {
                    ToastUtils.show(FlutterI18n.translate(context, "contact.name_hint"));
                    return;
                  }
                  if (contactName.length < 1 || contactName.length > 30) {
                    ToastUtils.show(FlutterI18n.translate(context, "contact.name_limit"));
                    return;
                  }
                  if (memo.length > 50) {
                    ToastUtils.show(FlutterI18n.translate(context, "contact.remark_tips"));
                    return;
                  }

                  //名字修改了，则需要判断是否重名
                  if (widget.contact.name != contactName) {
                    DbHelper.instance
                        .queryContactByName(contactName)
                        .then((list) {
                      if (list.length > 0) {
                        ToastUtils.show(FlutterI18n.translate(
                            context, "contact.name_exist"));
                      } else {
                        Navigator.of(context).pop();

                        DbHelper.instance
                            .updateContact(widget.contact.address,
                                widget.contact.name, contactName, memo)
                            .then((i) {
                          if (i > 0) {
                            ToastUtils.show(FlutterI18n.translate(context, "modify_success"));
                            eventBus.fire(ContactUpdateSuccess());
                          } else {
                            ToastUtils.show(FlutterI18n.translate(context, "modify_fail"));
                          }
                        });
                      }
                    });
                  } else {
                    Navigator.of(context).pop();

                    DbHelper.instance
                        .updateContact(widget.contact.address,
                            widget.contact.name, contactName, memo)
                        .then((i) {
                      if (i > 0) {
                        ToastUtils.show(FlutterI18n.translate(context, "modify_success"));
                        eventBus.fire(ContactUpdateSuccess());
                      } else {
                        ToastUtils.show(FlutterI18n.translate(context, "modify_fail"));
                      }
                    });
                  }
                },
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.save"),
                  style: TextStyle(
                      color: Color(AppColors.COLOR_PRIMARY),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  void showDeleteContactDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: FixedSizeText(FlutterI18n.translate(context, "tips")),
            content: SingleChildScrollView(
              child: FixedSizeText(FlutterI18n.translate(context, "delete_confirm")),
            ),
            actions: <Widget>[
              FlatButton(
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.cancel"),
                  style: TextStyle(
                    color: Color(AppColors.GREY_1),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.delete"),
                  style: TextStyle(
                    color: Color(AppColors.RED),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();

                  DbHelper.instance
                      .deleteContact(widget.contact.name, widget.contact.address)
                      .then((i) {
                    if (i > 0) {
                      ToastUtils.show(FlutterI18n.translate(context, "delete_success"));
                      eventBus.fire(ContactUpdateSuccess());
                    } else {
                      ToastUtils.show(FlutterI18n.translate(context, "delete_fail"));
                    }
                  });
                },
              ),
            ],
          );
        });
  }
}
