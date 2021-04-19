import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wallet/adapter/contact_item.dart';
import 'package:wallet/db/db_helper.dart';
import 'package:wallet/eventbus/event_bus.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/contact_model.dart';
import 'package:wallet/mvp/view/contact/contact_add_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 联系人列表
///

class ContactPage extends StatefulWidget {
  int option;

  ContactPage({this.option});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  ScrollController _scrollController = ScrollController();

  List<ContactModel> contactList;

  bool _isLoading = false;

  void initContactList(){
    setState(() {
      _isLoading = true;
    });
    DbHelper.instance.queryContactList().then((list) {
      handleData(list);
    });
  }

  void handleData(List<dynamic> list){
    if(contactList == null){
      contactList = List<ContactModel>();
    }
    if(contactList.isNotEmpty){
      contactList.clear();
    }
    list.forEach((element) {
      log('Contact.list.element = $element');
      contactList.add(ContactModel(
          name: element['name'],
          address: element['address'],
          memo: element['remark']));
    });
    if(mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    initContactList();

    eventBus.on<ContactUpdateSuccess>().listen((event) {
      DbHelper.instance.queryContactList().then((contactList){
        handleData(contactList);
      });
    });

    eventBus.on<ContactSelectedItem>().listen((event) {
      Navigator.of(context).pop(event.contact);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "contact.list"),
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_creat,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              navPush(context, ContactAddPage());
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
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
                    color: Color(AppColors.GREY_1), fontSize: 12.0),
              )
            ],
          ),
        ),
        child: _buildListView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context){
    if (contactList == null) {
      return Center(
        child: Container(
          color: Color(0x30000000),
        ),
      );
    }
    if(contactList.length == 0){
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
      itemCount: contactList.length,
      itemBuilder: (context, index) {
        return ContactItem(
          contact: contactList[index],
          option: widget.option,
          isLastone: index == contactList.length - 1,
        );
      },
    );
  }

}
