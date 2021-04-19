import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/delegation_item.dart';
import 'package:wallet/adapter/undelegation_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/delegation_model.dart';
import 'package:wallet/model/undelegation_model.dart';
import 'package:wallet/model/validator_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/delegation_contract.dart';
import 'package:wallet/mvp/presenter/delegation_presenter_impl.dart';
import 'package:wallet/mvp/view/validator/validator_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/system_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';
import 'package:wallet/widget/nestedscrollview/nested_scroll_view_refresh_indicator.dart';

import 'delegation_record_page.dart';

///
/// 委托页面
///
class DelegationPage extends StatefulWidget {
  @override
  _DelegationPageState createState() => _DelegationPageState();
}

class _DelegationPageState extends State<DelegationPage> with SingleTickerProviderStateMixin implements DelegationView {
  DelegationPresenterImpl mPresenter;

  WalletModel wallet = new WalletModel();

  ScrollController _scrollViewController;
  TabController _tabController;

  List<Map<String, String>> _tabTitleList = [
    {"key": "delegation.delegating", "type": "delegation"},
    {"key": "delegation.validators", "type": "validator"},
    {"key": "delegation.undelegating", "type": "undelegation"},
  ];

  //委托中的数据集合，验证人地址为key
  Map<String, DelegationModel> delegationMap = Map<String, DelegationModel>();
  //委托中
  List<DelegationModel> delegationList;
  //赎回中
  List<UndelegationModel> undelegationList;

  double delegationAmount = 0;
  double rewardAmount = 0;
  double availableAmount = 0;
  double undelegationAmount = 0;

  bool _isValidatorTab = false;

  Future<Null> _pullToRefresh() async {
    getWalletData();
    return null;
  }

  void getWalletData(){
    //初始化获取当前钱包信息
    SPUtils.getWalletInfo().then((walletInfo) {
      wallet = walletInfo;
      delegationMap.clear();
      mPresenter.getDelegationList(wallet.address);
      mPresenter.getBalance(wallet.address);
      mPresenter.getReward(wallet.address);
      mPresenter.getUndelegationList(wallet.address);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      if(_tabController.index == 1){
        log(' ----------- validator ------------ ');
        setState(() {
          _isValidatorTab = true;
        });
      } else {
        log(' ----------- delegation/undelegation ------------ ');
        setState(() {
          _isValidatorTab = false;
        });
      }
    });

    mPresenter = DelegationPresenterImpl(this);

    getWalletData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'delegation.title'),
          style: TextStyle(
            color: Color(AppColors.WHITE),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(AppColors.COLOR_PRIMARY),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              IconFont.ic_trade_record,
              size: 20.0,
              color: Color(AppColors.WHITE),
            ),
            onPressed: () {
              navPush(context, DelegationRecordPage());
            },
          ),
        ],
      ),
      body: NestedScrollViewRefreshIndicator(
        notificationPredicate: _isValidatorTab ? notNestedScrollViewScrollNotificationPredicate : nestedScrollViewScrollNotificationPredicate,
        onRefresh: _pullToRefresh,
        child: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (context, bool) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 279.0,
                floating: true,
                pinned: true,
                backgroundColor: Color(AppColors.MAIN_COLOR),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    height: double.infinity,
                    color: Color(AppColors.MAIN_COLOR),
                    child: Column(
                      children: [
                        _buildTopCardView(context),
                        Container(  //TabBar圆角背景颜色
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: _tabTitleList.map((item) {
                    return Tab(
                      text: FlutterI18n.translate(context, item['key']),
                    );
                  }).toList(),
                  indicatorColor: Color(AppColors.COLOR_PRIMARY),
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.only(bottom: 5.0),
                  unselectedLabelColor: Color(AppColors.GREY_1),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 13.0, fontWeight: FontWeight.bold),
                  labelColor: Color(AppColors.COLOR_PRIMARY),
                  labelStyle: TextStyle(
                      color: Color(AppColors.BLACK),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabTitleList.map((item) {
              if(item['type'] == "delegation"){
                return _buildDelegationListView(context);
              } else if(item['type'] == 'validator'){
                return ValidatorPage();
              } else {
                return _buildUndelegationListView(context);
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDelegationListView(BuildContext context){
    if(delegationList == null){
      return Center(
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
      );
    }
    if(delegationList.length == 0){
      return Center(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(IconFont.ic_no_data,
                    color: Color(AppColors.GREY_2), size: 50.0),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, top: 12.0, bottom: 20.0),
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
      physics: NeverScrollableScrollPhysics(),
      itemCount: delegationList.length,
      itemBuilder: (context, index) {
        return DelegationItem(delegation: delegationList[index]);
      },
    );
  }

  Widget _buildUndelegationListView(BuildContext context){
    if(undelegationList == null){
      return Center(
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
      );
    }
    if(undelegationList.length == 0){
      return Center(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(IconFont.ic_no_data,
                    color: Color(AppColors.GREY_2), size: 50.0),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, top: 12.0, bottom: 20.0),
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
      physics: NeverScrollableScrollPhysics(),
      itemCount: undelegationList.length,
      itemBuilder: (context, index){
        return UndelegationItem(undelegation: undelegationList[index]);
      },
    );
  }

  Widget _buildTopCardView(BuildContext context) {
    return Container(
      color: Color(AppColors.MAIN_COLOR),
      child: Stack(
        children: [
          Container(
            height: 170.0,
            decoration: BoxDecoration(
              color: Color(AppColors.COLOR_PRIMARY),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0)),
            ),
          ),
          Container(
            height: 229.0,
            margin: EdgeInsets.only(left: 15.0, right: 15.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 15.0, bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'delegation.total'),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5.0, bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FixedSizeText(
                        formatNum(delegationAmount, 6),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
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
                ),
                Divider(color: Color(AppColors.SP_LINE_2), height: 1.0),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 5.0, right: 5.0, top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'delegation.reward'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 14.0),
                      ),
                      FixedSizeText(
                        formatNum(rewardAmount, 6),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 5.0, right: 5.0, top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'delegation.available'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 14.0),
                      ),
                      FixedSizeText(
                        formatNum(availableAmount, 6),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 12.0, bottom: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FixedSizeText(
                        FlutterI18n.translate(context, 'delegation.undelegating'),
                        style: TextStyle(
                            color: Color(AppColors.GREY_1), fontSize: 14.0),
                      ),
                      FixedSizeText(
                        formatNum(undelegationAmount, 6),
                        style: TextStyle(
                            color: Color(AppColors.BLACK),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30.0,
            child: Container(
              width: SystemUtils.getWidth(context) - 30,
              child: Center(
                child: Image.asset(
                  'assets/images/card_bg_3.png',
                  width: 80.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void putData(String type, String validatorAddress, double amount) async {
    if(delegationMap[validatorAddress] == null) {
      delegationMap[validatorAddress] = DelegationModel(
          validatorName: 'Name',
          validatorAddress: validatorAddress);
      if(type == "delegation") {
        delegationMap[validatorAddress].delegationAmount = amount;
      } else {
        delegationMap[validatorAddress].rewardAmount = amount;
      }
    } else {
      if(type == "delegation") {
        delegationMap[validatorAddress].delegationAmount += amount;
      } else {
        delegationMap[validatorAddress].rewardAmount += amount;
      }
    }
  }

  List<DelegationModel> prepareDelegationList() {
    var list = delegationMap.values.toList();
    list.sort((left,right) => right.delegationAmount.compareTo(left.delegationAmount));
    return list;
  }

  @override
  void onResponseDelegationListData(Map<String, dynamic> response) {
    log('Delegation Delegation.Resp = $response');

    double amount = 0;

    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        var validatorAddress = f['validator_address'];
        var delegationAmountTmp = double.parse(f['balance']) / ChainParams.MAIN_TOKEN_UNIT;
        amount += double.parse(f ['balance']);

        putData("delegation", validatorAddress, delegationAmountTmp);
        mPresenter.getValidator(validatorAddress);
      });
    }
    setState(() {
      delegationAmount = amount / ChainParams.MAIN_TOKEN_UNIT;
      delegationList = prepareDelegationList();
    });
  }

  @override
  void onResponseRewardData(Map<String, dynamic> response) {
    log('Delegation Reward.Resp = $response');

    double amount = 0;

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      var rewards = result['rewards'];
      rewards.forEach((item) {
        var validatorAddress = item['validator_address'];
        var reward = item['reward'];
        if(reward != null) {//可能为null
          putData("reward", validatorAddress, double.parse(reward[0]['amount']) / ChainParams.MAIN_TOKEN_UNIT);
        }
        if(result['total'] != null) {//可能为null
          amount = double.parse(result['total'][0]['amount']) / ChainParams.MAIN_TOKEN_UNIT;
        }
      });
    }

    setState(() {
      rewardAmount = amount;
      delegationList = prepareDelegationList();
    });
  }

  @override
  void onResponseBalanceData(Map<String, dynamic> response) {
    log('Delegation Balance.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        //MainToken
        if (f['denom'] == ChainParams.MAIN_TOKEN_DENOM) {
          setState(() {
            availableAmount = double.parse(f['amount']) / ChainParams.MAIN_TOKEN_UNIT;
          });
          return;
        }
      });
    }
  }

  @override
  void onResponseUndelegationListData(Map<String, dynamic> response) {
    if(undelegationList == null){
      undelegationList = List<UndelegationModel>();
    }
    if(undelegationList.isNotEmpty){
      undelegationList.clear();
    }

    double amount = 0;

    log('Delegation Undelegation.Resp = $response');
    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((item) {
        item['entries'].forEach((entry) {
          var validatorAddress = item['validator_address'];
          mPresenter.getValidator(validatorAddress);
          undelegationList.add(UndelegationModel(
              validatorName: "Name",
              validatorAddress: validatorAddress,
              undelegationAmount: double.parse(entry['balance']) / ChainParams.MAIN_TOKEN_UNIT,
              completeDatetime: formatDatetime(parseDatetimeFromChain(entry['completion_time']))));

          amount += double.parse(entry['balance']);
        });
      });
    }
    setState(() {
      undelegationAmount = amount / ChainParams.MAIN_TOKEN_UNIT;
    });
  }

  @override
  void onResponseValidatorData(Map<String, dynamic> response) {

    log('Delegation Validator.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      var operatorAddress = result['operator_address'];
      var validatorName = result['description']['moniker'];
      var tokens = double.parse(result['tokens']);//受托总数
      var delegatorShares = double.parse(result['delegator_shares']);
      var commissionRate = double.parse(result['commission']['commission_rates']['rate']);

      var validator = ValidatorModel(
          validatorName: validatorName,
          bech32Address: convertValoperAddressToWalletAddress(operatorAddress),
          valoperAddress: operatorAddress,
          delegationAmount: tokens / ChainParams.MAIN_TOKEN_UNIT,
          tokens: tokens,
          delegatorShares: delegatorShares,
          commissionRate: commissionRate);
      // 设置“委托中”数据列表
      if (delegationMap[operatorAddress] != null) {
        delegationMap[operatorAddress].validator = validator;
        delegationMap[operatorAddress].validatorName = validatorName;
      }

      // 设置“赎回中”数据列表
      undelegationList.forEach((undelegationModel) {
        if (undelegationModel.validatorAddress == operatorAddress) {
          undelegationModel.validator = validator;
          undelegationModel.validatorName = validatorName;
        }
      });
      delegationList = prepareDelegationList();

      setState(() {
      });
    }
  }

  @override
  void dismissLoading() {
    // TODO: implement dismissLoading
  }

  @override
  void showLoading() {
    // TODO: implement showLoading
  }

  @override
  void showMessage(String msg) {
    // TODO: implement showMessage
  }
}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar widget;
  final Color color;

  const SliverTabBarDelegate(this.widget, {this.color})
      : assert(widget != null);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: widget,
      color: color,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => widget.preferredSize.height;

  @override
  double get minExtent => widget.preferredSize.height;
}
