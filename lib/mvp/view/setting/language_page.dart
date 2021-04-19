import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/main.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/welcome.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 语言切换
///

class LanguagePage extends StatefulWidget {
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  ScrollController _scrollController = ScrollController();

  List<dynamic> languageList = [
    {"language": "简体中文", "locale": "zh", "checked": true},
    {"language": "English", "locale": "en", "checked": false}
  ];

  void saveLocale() {
    new Future.delayed(Duration.zero, () async {
      String languageCode = "";
      languageList.forEach((element) {
        if (element["checked"]) {
          languageCode = element["locale"];
        }
      });
      log('languageCode = $languageCode');
      await FlutterI18n.refresh(context, Locale(languageCode));

      SPUtils.setLanguageCode(languageCode).then((val) {
        log('当前：$languageCode 保存成功！');
        main();
        navPushAndRemoveAll(context, WelcomePage(loginResult: 1, languageCode: languageCode));
      });
    });
  }

  void setCurrentLanguage(int index) {
    languageList[index]["checked"] = true;
    languageList.forEach((element) {
      if (element["locale"] != languageList[index]["locale"]) {
        element["checked"] = false;
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Locale currentLocale = FlutterI18n.currentLocale(context);
      languageList.forEach((element) {
        if (element["locale"] == currentLocale.languageCode) {
          element["checked"] = true;
        } else {
          element["checked"] = false;
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, "language"),
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
        actions: [
          Container(
            height: 30.0,
            width: 70.0,
            margin: EdgeInsets.only(
                left: 15.0, right: 15.0, top: 12.0, bottom: 12.0),
            child: RaisedButton(
              onPressed: saveLocale,
              color: Color(AppColors.COLOR_PRIMARY),
              highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: Center(
                child: FixedSizeText(
                  FlutterI18n.translate(context, "button.save"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: languageList.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(
              left: 15.0, right: 15.0, top: index == 0 ? 15.0 : 10.0),
          child: Material(
            color: Color(AppColors.WHITE),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: InkWell(
              onTap: () {
                setCurrentLanguage(index);
              },
              child: Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FixedSizeText(
                      languageList[index]['language'],
                      style: TextStyle(
                          color: Color(AppColors.BLACK),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      IconFont.ic_check_cirle,
                      size: 24.0,
                      color: languageList[index]["checked"]
                          ? Color(AppColors.COLOR_PRIMARY)
                          : Color(AppColors.GREY_2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
