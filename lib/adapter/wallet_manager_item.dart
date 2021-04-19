import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/view/issue/token_list_page.dart';
import 'package:wallet/mvp/view/qr/qr_code_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_backup_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_create_or_import_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_manager_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/common_bottom_sheet.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 钱包管理 Item
///

class WalletManagerItem extends StatefulWidget {
  WalletModel wallet;
  bool isLastone;

  WalletManagerItem({this.wallet, this.isLastone});

  @override
  _WalletManagerItemState createState() => _WalletManagerItemState();
}

class _WalletManagerItemState extends State<WalletManagerItem> {

  @override
  void initState() {
    super.initState();
  }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FixedSizeText(
                      widget.wallet.name,
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  FixedSizeText(
                    formatDate(
                        DateTime.fromMillisecondsSinceEpoch(
                            widget.wallet.createTime),
                        [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]),
                    style: TextStyle(
                        color: Color(AppColors.GREY_1), fontSize: 12.0),
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
                      QRCodePage(walletAddress: widget.wallet.address));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: FixedSizeText(
                      widget.wallet.address,
                      style: TextStyle(
                          color: Color(AppColors.GREY_1), fontSize: 14.0),
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
              padding:
                  const EdgeInsets.only(left: 16.0, right: 6.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FixedSizeText(
                        formatNum(
                            widget.wallet.balance / ChainParams.MAIN_TOKEN_UNIT, 6),
                        style: TextStyle(
                            color: Color(AppColors.COLOR_PRIMARY),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 3.0),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1.0),
                        child:
                          FixedSizeText(
                            ChainParams.MAIN_TOKEN_SHORT_NAME,
                            style: TextStyle(
                                color: Color(AppColors.GREY_1), fontSize: 11.0),
                          ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      showWalletEditDialog(context);
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
    );
  }

  void showWalletEditDialog(BuildContext context) {
    showDialog(
        barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
        context: context,
        builder: (BuildContext menuContext) {
          var list = List<CommonBottomModel>();
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "wallet.mnemonic_export"), itemLabelColor: Color(AppColors.COLOR_PRIMARY)));
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "issue.label_issue_token"), itemLabelColor: Color(AppColors.COLOR_PRIMARY)));
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "wallet.modify"), itemLabelColor: Color(AppColors.COLOR_PRIMARY)));
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "wallet.modify_password"), itemLabelColor: Color(AppColors.COLOR_PRIMARY)));
          list.add(CommonBottomModel(
              name: FlutterI18n.translate(context, "wallet.delete"), itemLabelColor: Color(AppColors.RED)));
          return CommonBottomSheet(
            itemList: list,
            onItemClickListener: (index) async {
              log('current.wallet.toString = ${widget.wallet.toString()}');
              Navigator.of(menuContext).pop();
              switch (index) {
                case 0:
                  WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, exportWallet);
                  break;
                case 1:
                  navPush(context, TokenListPage(widget.wallet));
                  break;
                case 2:
                  WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, showModifyWalletNameDialog);
                  break;
                case 3:
                  showModifyPasswordDialog(context);
                  break;
                case 4:
                  WalletManagerPage.showVerifyPasswordDialog(context, widget.wallet, deleteWallet);
                  break;
              }
            },
          );
        });
  }

  void exportWallet(BuildContext context) {
    List<String> mnemonicList =
        widget.wallet.mnemonic.trim().split(RegExp(r"(\s+)"));
    navPush(
        context,
        WalletBackupPage(
            mnemonicList, widget.wallet.name, widget.wallet.password,
            shouldHideButton: true));
  }

  ///修改钱包名称
  void showModifyWalletNameDialog(BuildContext context) {
    TextEditingController _walletNameTextEditingController =
        TextEditingController(text: widget.wallet.name);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 16.0),
            content: Container(
              height: 118.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconFont.ic_wallet,
                        size: 16.0,
                        color: Color(AppColors.GREY_1),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FixedSizeText(
                        FlutterI18n.translate(context, "wallet.modify"),
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
                      controller: _walletNameTextEditingController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(20)
                      ],
                      maxLines: 1,
                      style: TextStyle(
                          color: Color(AppColors.BLACK), fontSize: 14.0),
                      onChanged: (val) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: FlutterI18n.translate(context, "wallet.name_hint"),
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
                      FlutterI18n.translate(context, "wallet.name_limit"),
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
                  String walletName = _walletNameTextEditingController.text.trim();
                  if (walletName.isEmpty) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.name_hint"));
                    return;
                  }
                  if (walletName.length < 1 || walletName.length > 30) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.name_limit"));
                    return;
                  }
                  modifyWalletName(walletName);
                  Navigator.of(context).pop();
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

  void modifyWalletName(String walletName) {
    String address = widget.wallet.address;
    if (widget.wallet.name != walletName) {
      DbHelper.instance.queryWalletByName(walletName).then((walletList) {
        if (null != walletList && walletList.isNotEmpty) {
          walletList.forEach((e) {
            if (e['address'] != address) {
              ToastUtils.show(FlutterI18n.translate(context, "wallet.name_duplicated"));
              return;
            }
          });
        } else {
          DbHelper.instance
              .updateWalletNameByAddress(address, walletName)
              .then((i) {
            if (i > 0) {
              SPUtils.getWalletAddress().then((walletAddress) {
                if (walletAddress == address) {
                  SPUtils.setWalletName(walletName);
                }
              });
              ToastUtils.show(FlutterI18n.translate(context, "modify_success"));
              eventBus.fire(WalletModifyNameListener(address: address, walletName: walletName));
            } else {
              ToastUtils.show(FlutterI18n.translate(context, "modify_fail"));
            }
          });
        }
      });
    } else {
      // 没有修改名称，目前不需要做任何逻辑
    }
  }

  void deleteWallet(BuildContext context) {

    SPUtils.getWalletAddress().then((selectedAddress) {

      DbHelper.instance.deleteWalletByAddress(widget.wallet.address).then((i) {
        DbHelper.instance.queryWalletList().then((list) {
          if (list.isEmpty) {
            //已删除所有钱包，跳到创建/导入钱包页面
            SPUtils.clearWalletInfo().then((value) {
              navPushAndRemoveAll(context, WalletCreateOrImportPage());
            });
          } else {
            bool b = false;
            list.forEach((map) {
              if (map['address'] == selectedAddress) {
                b = true;
              }
            });

            if (b == false) {
              Map<String, dynamic> map = list[0];
              //删除了当前选中的钱包，默认重新选中最新创建的钱包
              DbHelper.instance
                  .updateSelectedWallet(map['address'])
                  .then((value) {
                ToastUtils.show(FlutterI18n.translate(context, "delete_success"));
                eventBus.fire(WalletDeleteListener(model: widget.wallet));

                WalletModel walletModel = WalletModel(
                    name: map['name'],
                    address: map['address'],
                    password: map['password'],
                    mnemonic: map['mnemonic'],
                    selected: true);
                SPUtils.setWalletModel(walletModel).then((value) {
                  eventBus.fire(WalletChangeSuccess(model: walletModel));
                });
              });
            } else {
              ToastUtils.show(FlutterI18n.translate(context, "delete_success"));
              eventBus.fire(WalletDeleteListener(model: widget.wallet));
            }
          }
        });
      });
    });
  }

  ///修改密码
  void showModifyPasswordDialog(BuildContext context) {
    TextEditingController _oldPasswordTextEditingController =
        TextEditingController();
    TextEditingController _newPasswordTextEditingController =
        TextEditingController();
    TextEditingController _renewPasswordTextEditingController =
        TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
//            title: new Text("title"),
            contentPadding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 20.0, bottom: 16.0),
            content: Container(
              height: 278.0,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          IconFont.ic_password,
                          size: 16.0,
                          color: Color(AppColors.GREY_1),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        FixedSizeText(
                          FlutterI18n.translate(context, "wallet.verify_password"),
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
                        controller: _oldPasswordTextEditingController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6) //限制长度
                        ],
                        maxLines: 1,
                        obscureText: true,
                        style: TextStyle(
                            color: Color(AppColors.BLACK), fontSize: 14.0),
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: FlutterI18n.translate(context, "wallet.old_password_hint"),
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
                    SizedBox(height: 15.0),
                    Row(
                      children: [
                        Icon(
                          IconFont.ic_password,
                          size: 16.0,
                          color: Color(AppColors.GREY_1),
                        ),
                        SizedBox(width: 10.0),
                        FixedSizeText(
                          FlutterI18n.translate(context, "wallet.new_password"),
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
                        controller: _newPasswordTextEditingController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6) //限制长度
                        ],
                        maxLines: 1,
                        obscureText: true,
                        style: TextStyle(
                            color: Color(AppColors.BLACK), fontSize: 14.0),
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: FlutterI18n.translate(context, "wallet.new_password_hint"),
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
                    SizedBox(height: 10.0),
                    Material(
                      color: Color(AppColors.MAIN_COLOR),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: TextField(
                        controller: _renewPasswordTextEditingController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6) //限制长度
                        ],
                        maxLines: 1,
                        obscureText: true,
                        style: TextStyle(
                            color: Color(AppColors.BLACK), fontSize: 14.0),
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: FlutterI18n.translate(context, "wallet.new_password_confirm_hint"),
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
                        FlutterI18n.translate(context, "wallet.password_limit"),
                        style: TextStyle(
                          color: Color(AppColors.GREY_2),
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  String oldPassword = _oldPasswordTextEditingController.text;
                  if (oldPassword.isEmpty) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.old_password_hint"));
                    return;
                  }
                  String newPassword = _newPasswordTextEditingController.text;
                  if (newPassword.isEmpty) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.new_password_hint"));
                    return;
                  }
                  if (newPassword.length < 2 || newPassword.length > 12) {
                    ToastUtils.show('钱包名称的长度为2-12个字');
                    return;
                  }
                  String renewPassword =
                      _renewPasswordTextEditingController.text;
                  if (renewPassword.isEmpty) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.password_confirm_empty"));
                    return;
                  }
                  if (newPassword != renewPassword) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.password_inconsistent"));
                    return;
                  }
                  if (widget.wallet.password != oldPassword) {
                    ToastUtils.show(FlutterI18n.translate(context, "wallet.wrong_old_password"));
                    return;
                  }
                  modifyWalletPassword(widget.wallet.address, newPassword);
                  Navigator.of(context).pop();
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

  @override
  void modifyWalletPassword(String address, String walletPassword) {
    DbHelper.instance.updateWalletPasswordByAddress(address, walletPassword).then((i){

      if (i > 0) {
        SPUtils.getWalletAddress().then((walletAddress) {
          if (walletAddress == address) {
            SPUtils.setWalletPassword(walletPassword);
          }
        });
        ToastUtils.show(FlutterI18n.translate(context, "modify_success"));
        eventBus.fire(WalletModifyPasswordListener(address: address, password: walletPassword));
      } else {
        ToastUtils.show(FlutterI18n.translate(context, "modify_fail"));
      }
    });
  }
}
