import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/mvp/view/delegation/record_delegation_list_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 委托记录
///
class DelegationRecordPage extends StatefulWidget {
  @override
  _DelegationRecordPageState createState() => _DelegationRecordPageState();
}

class _DelegationRecordPageState extends State<DelegationRecordPage> with SingleTickerProviderStateMixin {

  var _tabTitleList = [
    {"key": "delegation.delegation", "type": "delegation"},
    {"key": "delegation.undelegation", "type": "undelegation"},
    {"key": "delegation.reward", "type": "reward"},
    {"key": "validator.commission", "type": "commission"},
  ];

  // 缓存validatorName，留给流水页面的4个tab页调用，减少不必要的api调用
  Map<String, String> validatorNames = Map<String, String>();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'delegation.record.title'),
          style: TextStyle(
            color: Color(AppColors.BLACK),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(AppColors.MAIN_COLOR),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
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
              IconFont.ic_question,
              size: 20.0,
              color: Color(AppColors.BLACK),
            ),
            onPressed: () {
              showTipDialog();
            },
          ),
        ],
      ),
      backgroundColor: Color(AppColors.MAIN_COLOR),
      body: _buildDelegationRecordTabView(context),
    );
  }

  Widget _buildDelegationRecordTabView(BuildContext context) {
    return Column(
      children: [
        Container(
          child: TabBar(
            tabs: _tabTitleList.map((item) {
              return Tab(
                text: FlutterI18n.translate(context, item['key']),
              );
            }).toList(),
            indicatorColor: Color(AppColors.COLOR_PRIMARY),
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
//            indicatorPadding: EdgeInsets.only(bottom: 5.0),
            labelPadding: EdgeInsets.symmetric(horizontal: 5),
            labelColor: Color(AppColors.COLOR_PRIMARY),
            labelStyle: TextStyle(
              fontSize: 14.0,
              color: Color(0xffFF7E98),
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelColor: Color(AppColors.GREY_1),
            unselectedLabelStyle: TextStyle(fontSize: 12.0),
            controller: _tabController,
          ),
        ),
        Divider(
          height: 2.0,
          color: Color(AppColors.SP_LINE_2),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabTitleList.map((item) {
              return RecordDelegationListPage(item['type'], validatorNames);
            }).toList(),
          ),
        ),
      ],
    );
  }

  void showTipDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: FixedSizeText(FlutterI18n.translate(context, 'delegation.tip_delegation_record_title'),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
            content: SingleChildScrollView(
              child: FixedSizeText(
                FlutterI18n.translate(context, 'delegation.tip_delegation_record_content'),
                style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 14.0, height: 1.5),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Color(AppColors.COLOR_PRIMARY),
                highlightColor: Color(AppColors.COLOR_PRIMARY_HIGHLIGHT),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                child: FixedSizeText(
                  FlutterI18n.translate(context, 'button.cancel'),
                  style: TextStyle(color: Color(AppColors.WHITE)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}
