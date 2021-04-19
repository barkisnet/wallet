import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/validator_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/validator_model.dart';
import 'package:wallet/mvp/contract/validator_list_contract.dart';
import 'package:wallet/mvp/presenter/validator_list_presenter_impl.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 有、无效验证人列表
///

class ValidatorListPage extends StatefulWidget {
  String validatorStatus;

  ValidatorListPage({this.validatorStatus});

  @override
  _ValidatorListPageState createState() => _ValidatorListPageState();
}

class _ValidatorListPageState extends State<ValidatorListPage> with AutomaticKeepAliveClientMixin implements ValidatorListView {
  static const int VALIDATOR_REQUEST_LIMIT = 100;

  ValidatorListPresenter mPresenter;

  ScrollController _scrollController = ScrollController();

  List<ValidatorModel> validatorList;

  int pageIndex = 1;

  bool _isEmpty = true;
  bool _isBottom = false;
  bool _isMore = true;

  int callApiCount = 0;

  Future<Null> _pullToRefresh() async {
    callApiCount = 0;
    pageIndex = 1;
    getValidatorList();
    return null;
  }

  Future<Null> _loadMoreData() async {
    pageIndex += 1;
    getValidatorList();
    return null;
  }

  void getValidatorList(){
    if (widget.validatorStatus == 'active') {
      mPresenter.getValidatorList("bonded", pageIndex, VALIDATOR_REQUEST_LIMIT);
    } else {
      mPresenter.getValidatorList("unbonded", pageIndex, VALIDATOR_REQUEST_LIMIT);
      mPresenter.getValidatorList("unbonding", pageIndex, VALIDATOR_REQUEST_LIMIT);
    }
  }

  //AutomaticKeepAliveClientMixin 需添加
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mPresenter = ValidatorListPresenterImpl(this);
    getValidatorList();

    //给_controller添加监听
    _scrollController.addListener(() {
      //判断是否滑动到了页面的最底部
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        //请求加载更多数据
        if(!_isBottom) {
          setState(() {
            _isMore = true;
          });
          _loadMoreData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: _buildListView(context),
        onRefresh: _pullToRefresh,
      ),
    );
  }

  Widget _buildListView(BuildContext context){
    if(validatorList == null){
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
    if(_isEmpty){
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
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      padding: EdgeInsets.only(top: 10.0),
      itemCount: validatorList.length + 1,
      itemBuilder: (context, index) {
        if (index == validatorList.length) {
          return _isBottom ? Container(
            height: 60.0,
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, 'loading_finished'),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Color(AppColors.GREY_2),
                ),
              ),
            ),
          ) : _isMore ? Container(
            child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Color(AppColors.COLOR_PRIMARY)),
//                          backgroundColor: Theme.of(context).primaryColor,
                          strokeWidth: 2.0,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        FlutterI18n.translate(context, 'loading_more'),
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.GREY_1),
                        ),
                      )
                    ],
                  ),
                )
            ),
          ) : Center(
            child: Material(
              child: InkWell(
                child: Container(
                  height: 60.0,
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: FixedSizeText(
                      FlutterI18n.translate(context, 'click_load_more'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isMore = true;
                  });
                  pageIndex += 1;
                  getValidatorList();
                },
              ),
            ),
          );
        }
        return ValidatorItem(
          validator: validatorList[index],
          validatorStatus: widget.validatorStatus,
        );
      },
    );
  }

  @override
  void onResponseValidatorListData(Map<String, dynamic> response) {
    log('ValidatorList.Resp = $response');

    if(validatorList == null){
      validatorList = List<ValidatorModel>();
    }
    if(pageIndex == 1) {
      if (widget.validatorStatus == 'active'){
        if (validatorList.isNotEmpty) {
          validatorList.clear();
        }
      } else {
        if(callApiCount == 0){
          if (validatorList.isNotEmpty) {
            validatorList.clear();
          }
        }
        callApiCount++;
      }
    }

    var result = response['result'];
    List<ValidatorModel> tempList = new List<ValidatorModel>();
    if (result != null && result.isNotEmpty) {
      result.forEach((item) {
        var operatorAddress = item['operator_address'];
        var tokens = double.parse(item['tokens']);//受托总数
        var delegatorShares = double.parse(item['delegator_shares']);
        var commissionRate =
            double.parse(item['commission']['commission_rates']['rate']);
        tempList.add(ValidatorModel(
            validatorName: item['description']['moniker'],
            bech32Address: convertValoperAddressToWalletAddress(operatorAddress),
            valoperAddress: operatorAddress,
            delegationAmount: tokens / ChainParams.MAIN_TOKEN_UNIT,
            tokens: tokens,
            delegatorShares: delegatorShares,
            commissionRate: commissionRate,
            jailed: item['jailed'],
        ));
      });
      validatorList.addAll(tempList);
      validatorList.sort((left,right) => right.delegationAmount.compareTo(left.delegationAmount));
    }

    if(validatorList.isNotEmpty){
      setState(() {
        _isEmpty = false;
      });
    }

    if(tempList.isEmpty || tempList.length < VALIDATOR_REQUEST_LIMIT){
      setState(() {
        _isBottom = true;
      });
    } else {
      setState(() {
        _isBottom = false;
        _isMore = false;
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
