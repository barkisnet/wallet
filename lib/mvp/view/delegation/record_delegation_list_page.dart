import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/record_delegation_undelegation_item.dart';
import 'package:wallet/adapter/record_reward_commission_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/record_delegation_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/record_delegation_list_contract.dart';
import 'package:wallet/mvp/presenter/record_delegation_list_presenter_impl.dart';
import 'package:wallet/net/tx_service.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/utils/shared_preferences_utils.dart';
import 'package:wallet/utils/string_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 委托流水页面
///
class RecordDelegationListPage extends StatefulWidget {
  String type;
  Map<String, String> validatorNames;
  RecordDelegationListPage(this.type, this.validatorNames);

  @override
  _RecordDelegationListPageState createState() => _RecordDelegationListPageState();
}

class _RecordDelegationListPageState extends State<RecordDelegationListPage> with AutomaticKeepAliveClientMixin implements RecordDelegationListView {
  static const int DELEGATION_REQUEST_LIMIT = 5;

  RecordDelegationListPresenterImpl mPresenter;
  WalletModel wallet = new WalletModel();

  ScrollController _scrollController = ScrollController();

  List<RecordDelegationModel> recordList;

  int pageIndex = 1;

  bool _isEmpty = true;
  bool _isBottom = false;
  bool _isMore = true;

  //AutomaticKeepAliveClientMixin 需添加
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mPresenter = RecordDelegationListPresenterImpl(this);

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

  void getParamsForList(){
    SPUtils.getWalletInfo().then((walletInfo) {
      wallet = walletInfo;
      if(widget.type == "delegation") {
        mPresenter.getParamsForDelegationList(wallet.address);
      } else if(widget.type == "undelegation") {
        mPresenter.getParamsForUndelegationList(wallet.address);
      } else if(widget.type == "reward") {
        mPresenter.getParamsForRewardList(wallet.address);
      } else if(widget.type == "commission") {
        var valoperAddress = convertWalletAddressToValoperAddress(wallet.address);
        mPresenter.getParamsForCommissionList(valoperAddress);
      }
    });
  }

  Future<Null> _pullToRefresh() async {
    getParamsForList();
    return null;
  }

  Future<Null> _loadMoreData() async {
    if (pageIndex > 0) {
      loadData();
    }
    return null;
  }

  void doData(Map<String, dynamic> response) {
    List<dynamic> txList = response['txs'];
    int pageNumber = int.parse(response['page_number']);
    if (txList != null && txList.isNotEmpty) {

      txList.forEach((tx) {
        bool success = true;
        String delegatorAddress = "";
        String validatorAddress = "";
        List<dynamic> logs = tx['logs'];
        List<dynamic> msgs = tx['tx']['value']['msg'];
        var msgType = null;

        for (int msgIndex = 0; msgIndex < msgs.length; msgIndex++) {//循环，可能会有多对多转账交易，在当前app里，只有1个
          var msg = msgs[msgIndex];
          msgType = msg['type'];

          if (msgType == TxService.MSG_TYPE_DELEGATE ||
              msgType == TxService.MSG_TYPE_UNDELEGATE ||
              msgType == TxService.MSG_TYPE_WITHDRAW_REWARD ||
              msgType == TxService.MSG_TYPE_WITHDRAW_COMMISSION) {
            var valueBean = msg['value'];
            delegatorAddress = valueBean['delegator_address'];
            validatorAddress = valueBean['validator_address'];

            if (delegatorAddress == null || delegatorAddress.isEmpty) {//在领取佣金的时候delegatorAddress是空的，用验证人地址转换为委托人地址
              delegatorAddress = convertValoperAddressToWalletAddress(validatorAddress);
            }
          }

          logs.forEach((log) {
            if(log['msg_index'] == msgIndex) {
              success = log['success'];
              return;
            }
          });
        }

        double amount = 0;
        List<dynamic> events = tx['events'];
        events.forEach((event) {//抓取委托、赎回、领取的金额
          var eventType = event['type'];
          if (eventType == "delegate" || eventType == "unbond" || eventType == "withdraw_rewards" || eventType == "withdraw_commission") {
            event['attributes'].forEach((attr) {
              if (attr['key'] == 'amount') {
                String value = attr['value'];
                if(value != null){
                  amount = double.parse(value.replaceAll(ChainParams.MAIN_TOKEN_DENOM, ""));
                }
                return;
              }
            });
          }
        });

        double rewardAmount = 0;
        // 委托与赎回都会自动领取收益，下面的代码只会在委托与赎回操作的时候执行
        // 为了重用model类，领取收益的收益信息会放在amount字段
        if (msgType == TxService.MSG_TYPE_DELEGATE ||
            msgType == TxService.MSG_TYPE_UNDELEGATE) {
          events.forEach((event) {
            if (event['type'] == "transfer") {
              var attributes = event['attributes'];
              for (int i = 0; i < attributes.length; i++) {
                var recipientAttribute = attributes[i];
                if (recipientAttribute['key'] == 'recipient' &&
                    recipientAttribute['value'] == delegatorAddress) {
                  var rewardAttribute = attributes[i + 1];
                  String value = rewardAttribute['value'];
                  if(value != null){
                    rewardAmount = double.parse(value.replaceAll(ChainParams.MAIN_TOKEN_DENOM, ""));
                  }
                  return;
                }
              }
            }
          });
        }

        var timestamp = tx['timestamp'];

        var typeLabel = "";
        if (widget.type == "delegation") {
          typeLabel = FlutterI18n.translate(context, "delegation.delegated_amount");
        } else if (widget.type == "undelegation") {
          typeLabel = FlutterI18n.translate(context, "delegation.undelegated_amount");
        } else if (widget.type == "reward") {
          typeLabel = FlutterI18n.translate(context, "delegation.reward_amount");
        } else {
          typeLabel = FlutterI18n.translate(context, "validator.commission_amount");
        }

        var validatorName = "";
        if (widget.validatorNames.containsKey(validatorAddress)) {
          validatorName = widget.validatorNames[validatorAddress];
        } else {//对于实例变量已经缓存的验证人名称，不再调用api获取validatorName
          mPresenter.getValidator(validatorAddress);
        }

        recordList.add(RecordDelegationModel(
            type: widget.type,
            typeLabel: typeLabel,
            validatorName: validatorName,
            successful: success,
            amount: formatNum(amount / ChainParams.MAIN_TOKEN_UNIT, 6),
            rewardAmount: formatNum(rewardAmount / ChainParams.MAIN_TOKEN_UNIT, 6),
            shortValidatorAddress: formatShortAddress(validatorAddress),
            longValidatorAddress: validatorAddress,
            datetime: parseDatetimeFromChain(timestamp)));
      });

      setState(() {
        //按照时间降序排列
        recordList.sort((left,right) => right.datetime.compareTo(left.datetime));
      });

      if(recordList.isNotEmpty){
        setState(() {
          _isEmpty = false;
        });
      }
    }

    if(pageIndex == 1){
      setState(() {
        _isBottom = true;
      });
    } else {
      setState(() {
        _isBottom = false;
        _isMore = false;
      });
      pageIndex--;
    }
    //一旦发现最后一页数据<分页数的一半，且不是最后一页，则继续加载下一页
    if (recordList.length < DELEGATION_REQUEST_LIMIT && pageNumber != 1) {
      setState(() {
        _isMore = true;
      });
      loadData();
    }
  }

  @override
  void onResponseParamsForListData(Map<String, dynamic> response) {
    var totalCount = int.parse(response['total_count']);
    pageIndex = (totalCount/DELEGATION_REQUEST_LIMIT).ceil();

    log('pageIndex = $pageIndex');

    if(recordList == null){
      recordList = List<RecordDelegationModel>();
    }
    if(recordList.isNotEmpty){
      recordList.clear();
    }

    if (totalCount > 0) {//若第一次获取数据参数，获取的数据集是空，则不再继续获取数据
      loadData();
    } else {
      setState(() {
        _isEmpty = true;
        _isBottom = true;
        _isMore = false;
      });
    }
  }

  void loadData() {
    if (pageIndex < 1) {
      return;
    }
    
    if(widget.type == "delegation") {
      mPresenter.getDelegationList(wallet.address, pageIndex, DELEGATION_REQUEST_LIMIT);
    } else if(widget.type == "undelegation") {
      mPresenter.getUndelegationList(wallet.address, pageIndex, DELEGATION_REQUEST_LIMIT);
    } else if(widget.type == "reward") {
      mPresenter.getRewardList(wallet.address, pageIndex, DELEGATION_REQUEST_LIMIT);
    } else if(widget.type == "commission") {
      var valoperAddress = convertWalletAddressToValoperAddress(wallet.address);
      mPresenter.getCommissionList(valoperAddress, pageIndex, DELEGATION_REQUEST_LIMIT);
    }
  }

  @override
  void onResponseDelegationListData(Map<String, dynamic> response) {
    log('Record_Delegation_List.Resp = $response');
    doData(response);
  }

  @override
  void onResponseUndelegationListData(Map<String, dynamic> response) {
    log('Record_Undelegation_List.Resp = $response');
    doData(response);
  }

  @override
  void onResponseRewardListData(Map<String, dynamic> response) {
    log('Record_Reward_List.Resp = $response');
    doData(response);
  }

  @override
  void onResponseCommissionListData(Map<String, dynamic> response) {
    log('Record_Commission_List.Resp = $response');
    doData(response);
  }

  @override
  void onResponseValidatorData(Map<String, dynamic> response) {
    log('Record Validator.Resp = $response');

    var result = response['result'];
    if (result != null && result.isNotEmpty) {
      var operatorAddress = result['operator_address'];
      var validatorName = result['description']['moniker'];

      recordList.forEach((recordDelegationModel) {
        if (recordDelegationModel.longValidatorAddress == operatorAddress) {
          recordDelegationModel.validatorName = validatorName;
          // 缓存validatorName，减少API调用
          widget.validatorNames[operatorAddress] = validatorName;
          return;
        }
      });

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: _buildListView(),
        onRefresh: _pullToRefresh,
      ),
    );
  }

  ///数据列表
  Widget _buildListView() {
    if (recordList == null) {
      getParamsForList();
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
              style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    }
    if (_isEmpty) {
      return Center(
        child: Material(
          child: InkWell(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(IconFont.ic_no_data, color: Color(AppColors.GREY_2), size: 50.0),
                    Padding(
                      padding: const EdgeInsets.only(left:15.0, top: 12.0, bottom: 20.0),
                      child: FixedSizeText(
                        FlutterI18n.translate(context, "no_data_refresh"),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0, color: Color(AppColors.GREY_2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              setState(() {
                if (!mounted) return;
                recordList = null;
              });
            },
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: recordList.length + 1,
      itemBuilder: (context, index) {
        if (index == recordList.length) {
          return _isBottom ? Container(
            height: 60.0,
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "loading_finished"),
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
                        FlutterI18n.translate(context, "loading_more"),
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
                      FlutterI18n.translate(context, "click_load_more"),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isMore = true;
                  });
                  loadData();
                },
              ),
            ),
          );
        }
        if(widget.type == "delegation" || widget.type == "undelegation") {
          return RecordDelegationUndelegationItem(
            model: recordList[index],
          );
        } else if(widget.type == "reward") {
          return RecordRewardCommissionItem(
            model: recordList[index],
          );
        } else {
          return RecordRewardCommissionItem(
            model: recordList[index],
          );
        }
      },
    );
  }
}
