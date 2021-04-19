import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wallet/adapter/wallet_manager_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/wallet_manager_contract.dart';
import 'package:wallet/mvp/presenter/wallet_manager_presenter_impl.dart';
import 'package:wallet/mvp/view/wallet/wallet_create_page.dart';
import 'package:wallet/mvp/view/wallet/wallet_import_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/widget/common/single_bottom_sheet.dart';

///
/// 钱包管理页面
///

class WalletManagerPage extends StatefulWidget {
  @override
  _WalletManagerPageState createState() => _WalletManagerPageState();

  ///验证密码
  static void showVerifyPasswordDialog(BuildContext buildContext, WalletModel wallet, Function callback) {
    TextEditingController _verifyPasswordTextEditingController = TextEditingController();
    FocusNode _verifyPasswordFocusNode = FocusNode();

    String _passwordErrorHint = "";

    showDialog(
        context: buildContext,
        builder: (context) {
          _verifyPasswordFocusNode.requestFocus();
          return StatefulBuilder(
            builder: (context, mSetState){
              return new AlertDialog(
//            title: new Text("title"),
                contentPadding: EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20.0, bottom: 16.0),
                content: Container(
                  height: _passwordErrorHint.isEmpty ? 88 : 116.0,
                  child: Column(
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
                          focusNode: _verifyPasswordFocusNode,
                          controller: _verifyPasswordTextEditingController,
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
//                        setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: FlutterI18n.translate(context, "wallet.password_hint"),
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
                      _passwordErrorHint.isEmpty ? Offstage() : Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 5.0),
                        child: FixedSizeText(
                          _passwordErrorHint,
                          style: TextStyle(
                              color: Color(AppColors.RED),
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
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
                      String verifyPassword = _verifyPasswordTextEditingController.text;
                      log('verifyPassword = $verifyPassword');
                      if (verifyPassword.isEmpty) {
//                    ToastUtils.show(FlutterI18n.translate(context, "wallet.password_hint"));
                        mSetState((){
                          _passwordErrorHint = FlutterI18n.translate(context, "wallet.password_hint");
                        });
                        return;
                      }
                      log('widget.wallet.password = ${wallet.password}');
                      if (wallet.password != verifyPassword) {
//                    ToastUtils.show(FlutterI18n.translate(context, "wallet.wrong_password"));
                        mSetState((){
                          _passwordErrorHint = FlutterI18n.translate(context, "wallet.wrong_password");
                        });
                        return;
                      }

                      mSetState((){
                        _passwordErrorHint = "";
                      });

                      Navigator.of(context).pop();

                      callback(buildContext);
                      //_doSendTx();
                    },
                    child: FixedSizeText(
                      FlutterI18n.translate(context, "button.ok"),
                      style: TextStyle(
                          color: Color(AppColors.COLOR_PRIMARY),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }
}

class _WalletManagerPageState extends State<WalletManagerPage>
    implements WalletManagerView {
  WalletManagerPresenterImpl mPresenter;

  ScrollController _scrollController = ScrollController();

  List<WalletModel> walletList;

  bool _isLoading = false;

  void initWalletList(){
    showLoading();
    DbHelper.instance.queryWalletList().then((list) {
      if(walletList == null) {
        walletList = List<WalletModel>();
      }
      if(walletList.isNotEmpty){
        walletList.clear();
      }
      list.forEach((element) {
        log('change.wallet = $element');
        walletList.add(WalletModel(
            name: element['name'],
            address: element['address'],
            password: element['password'],
            mnemonic: element['mnemonic'],
            createTime: element['createTime'],
            selected: element['selected'] > 0));
      });
      if(mounted) {
        setState(() {});
      }
      walletList.forEach((wallet) {
        mPresenter.getBalances(wallet.address);
      });
    });
  }

  void modifyWalletNameUpdateListView(String address, String walletName){
    walletList.forEach((f) {
      if(address == f.address){
        f.name = walletName;
      }
    });
    if(mounted){
      setState(() {});
    }
  }

  void deleteWalletUpdateListView(WalletModel walletModel){
    bool b = walletList.remove(walletModel);
    if(b) {
      if(mounted){
        setState(() {});
      }
    }
  }

  void modifyPaswordUpdateListView(String address, String newPassword){
    walletList.forEach((f) {
      if(address == f.address){
        f.password = newPassword;
      }
    });
    if(mounted){
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    mPresenter = WalletManagerPresenterImpl(this);

    initWalletList();

    eventBus.on<WalletModifyNameListener>().listen((event) {
      modifyWalletNameUpdateListView(event.address, event.walletName);
    });

    eventBus.on<WalletDeleteListener>().listen((event) {
      deleteWalletUpdateListView(event.model);
    });

    eventBus.on<WalletModifyPasswordListener>().listen((event) {
      modifyPaswordUpdateListView(event.address, event.password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "wallet.title"),
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_creat,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              showWalletDialog(context);
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        color: Colors.transparent,
        progressIndicator: Container(
          width: SystemUtils.getWidth(context),
          height: SystemUtils.getHeight(context) - 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CupertinoActivityIndicator(),
              SizedBox(
                height: 8.0,
              ),
              FixedSizeText(
                FlutterI18n.translate(context, "loading"),
                style: TextStyle(
                    color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        child: _buildListView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context){
    if (walletList == null) {
      return Center(
        child: Container(
          color: Colors.transparent,
        ),
      );
    }
    if(walletList.length == 0){
      return Center(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(IconFont.ic_no_data, color: Color(AppColors.GREY_2), size: 50.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 12.0, bottom: 20.0),
                  child: FixedSizeText(
                    FlutterI18n.translate(context, "no_data"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.0, color: Color(AppColors.GREY_2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: walletList.length,
      itemBuilder: (context, index) {
        return WalletManagerItem(
          wallet: walletList[index],
          isLastone: index == walletList.length - 1,
        );
      },
    );
  }

  void showWalletDialog(BuildContext context) {
    showDialog(
        barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
        context: context,
        builder: (BuildContext context) {
          var list = List<SingleBottomModel>();
          list.add(SingleBottomModel(name: FlutterI18n.translate(context, "wallet.create"), iconData: IconFont.ic_creat_pocket, iconColor: Color(AppColors.GREEN)));
          list.add(SingleBottomModel(name: FlutterI18n.translate(context, "wallet.import"), iconData: IconFont.ic_import_pocket, iconColor: Color(AppColors.BLUE)));
          return SingleBottomSheet(
            itemList: list,
            onItemClickListener: (index) async {
              Navigator.pop(context);
              if(index == 0){
                navPush(context, WalletCreatePage());
              } else {
                navPush(context, WalletImportPage());
              }
            },
          );
        });
  }

  @override
  void onResponseBalanceData(Map<String, dynamic> response, String address) {
    log('Balance.Resp = $response');
    dismissLoading();
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        if (ChainParams.MAIN_TOKEN_DENOM == f['denom']) {
          walletList.forEach((wallet) {
            if (wallet.address == address) {
              wallet.balance = double.parse(f['amount']);
            }
          });
        }
      });
    }
  }

  @override
  void showLoading() {
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void dismissLoading() {
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void showMessage(String msg) {
    ToastUtils.show(msg);
  }
}
