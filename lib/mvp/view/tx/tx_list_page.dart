import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/asset_tx_item.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/asset_tx_model.dart';
import 'package:wallet/mvp/contract/token_list_contract.dart';
import 'package:wallet/mvp/presenter/token_list_presenter_impl.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/date_utils.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/number_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 交易流水Tab页
///
class TxListPage extends StatefulWidget {
  String type;
  String denom;
  String walletAddress;

  TxListPage(this.type, this.denom, this.walletAddress);

  @override
  _TxListPageState createState() => _TxListPageState();
}

class _TxListPageState extends State<TxListPage> implements TokenListView {
  static const int TX_REQUEST_LIMIT = 10;

  TokenListPresenterImpl mPresenter;

  ScrollController _scrollController = new ScrollController();

  List<AssetTxModel> txList;

  int pageIndex = 1;

  bool _isEmpty = true;
  bool _isBottom = false;
  bool _isMore = true;

  @override
  void initState() {
    super.initState();
    mPresenter = TokenListPresenterImpl(this);

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
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void getParamsTxList(){
    if (widget.type == "in") {
      mPresenter.getParamsForInTxList(widget.walletAddress);
    } else {
      mPresenter.getParamsForOutTxList(widget.walletAddress);
    }
  }

  void loadData() {
    if (widget.type == "in") {
      mPresenter.getInTxList(widget.walletAddress, pageIndex, TX_REQUEST_LIMIT);
    } else {
      mPresenter.getOutTxList(widget.walletAddress, pageIndex, TX_REQUEST_LIMIT);
    }
  }

  Future<Null> _pullToRefresh() async {
    getParamsTxList();
    return null;
  }

  Future<Null> _loadMoreData() async {
    if (pageIndex > 0) {
      loadData();
    }
    return null;
  }

  @override
  void onResponseParamsForTxData(Map<String, dynamic> response) {
    int totalCount = int.parse(response['total_count']);
    pageIndex = (totalCount/TX_REQUEST_LIMIT).ceil();

    if (txList == null) {
      txList = List<AssetTxModel>();
    }
    if(txList.isNotEmpty){
      txList.clear();
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

  @override
  void onResponseTxData(Map<String, dynamic> response) {
    log('Tx List.Resp = $response');

    int pageNumber = int.parse(response['page_number']);

    List<dynamic> txs = response['txs'];
    if (txs != null && txs.isNotEmpty) {
      txs.forEach((tx) {
        var hash = tx['txhash'];
        var timestamp = tx['timestamp'];

        var value = tx['tx']['value']['msg'][0]['value'];
        String fromAddress = value['from_address'];
        String toAddress = value['to_address'];
        var list = value['amount'];

        double amount = 0;
        list.forEach((coin) {
          if (coin['denom'] == widget.denom) {
            amount = double.parse(coin['amount']);

            bool isOut;
            var address = null;
            if (widget.type == 'out') {
              address = toAddress;
              isOut = true;
            } else {
              address = fromAddress;
              isOut = false;
            }

            var item = AssetTxModel(
                hash: hash,
                address: address,
                datetime: parseDatetimeFromChain(timestamp),
                amount: formatNum(amount / ChainParams.MAIN_TOKEN_UNIT, 2),
                isOut: isOut);
            txList.add(item);
            return;
          }
        });
      });

      setState(() {
        //按照时间降序排列
        txList.sort((left,right) => right.datetime.compareTo(left.datetime));
      });

      if(txList.isNotEmpty){
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

    //一旦发现最后一页数据 小于 分页数的一半，则继续加载下一页
    if (txList.length * 2 < TX_REQUEST_LIMIT  && pageNumber != 1) {
      setState(() {
        _isMore = true;
      });
      loadData();
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
    if (txList == null) {
      getParamsTxList();
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
                txList = null;
              });
            },
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: txList.length + 1,
      itemBuilder: (context, index) {
        if (index == txList.length) {
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
                      style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0),
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
        return AssetTxItem(model: txList[index]);
      },
    );
  }

}
