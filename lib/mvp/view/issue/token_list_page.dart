import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wallet/adapter/issue_token_item.dart';
import 'package:wallet/icons/iconfont.dart';
import 'package:wallet/model/issue_token_model.dart';
import 'package:wallet/model/wallet_model.dart';
import 'package:wallet/mvp/contract/issue_list_contract.dart';
import 'package:wallet/mvp/presenter/issue_list_presenter_impl.dart';
import 'package:wallet/mvp/view/issue/issue_token_page.dart';
import 'package:wallet/utils/constants.dart';
import 'package:wallet/utils/log_utils.dart';
import 'package:wallet/utils/navigator_utils.dart';
import 'package:wallet/utils/toast_utils.dart';
import 'package:wallet/widget/common/fixed_size_text.dart';

///
/// 通证发行列表页面
///

class TokenListPage extends StatefulWidget {
  WalletModel wallet;

  TokenListPage(this.wallet);

  @override
  _TokenListPageState createState() => _TokenListPageState();
}

class _TokenListPageState extends State<TokenListPage> implements IssueListView {
  static const int TOKEN_REQUEST_LIMIT = 5;

  IssueListPresenterImpl mPresenter;

  ScrollController _scrollController = ScrollController();

  List<IssueTokenModel> dataList;

  var symbols = <String>{};

  int pageIndex = 1;

  bool _isEmpty = true;
  bool _isBottom = false;
  bool _isMore = true;

  @override
  void initState() {
    super.initState();

    mPresenter = IssueListPresenterImpl(this);

    //给_controller添加监听
    _scrollController.addListener(() {
      //判断是否滑动到了页面的最底部
      log('_scrollController.position.pixels = ${_scrollController.position.pixels}');
      log('_scrollController.position.maxScrollExtent = ${_scrollController.position.maxScrollExtent}');
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //请求加载更多数据
        if (!_isBottom) {
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

  Future<Null> _pullToRefresh() async {
    pageIndex = 1;
    mPresenter.getIssueList(pageIndex, TOKEN_REQUEST_LIMIT);
    return null;
  }

  Future<Null> _loadMoreData() async {
    pageIndex += 1;
    mPresenter.getIssueList(pageIndex, TOKEN_REQUEST_LIMIT);
    return null;
  }

  @override
  void onResponseIssueListData(Map<String, dynamic> response) {
    if (dataList == null) {
      dataList = List<IssueTokenModel>();
    }
    if (pageIndex == 1) {
      dataList.clear();
    }

    log('onResponseIssueListData.Resp = $response');

    List<dynamic> result = response['result'];
    if (result != null && result.isNotEmpty) {
      result.forEach((f) {
        symbols.add(f['symbol']);
        if (widget.wallet.address == f['owner']) {
          dataList.add(IssueTokenModel(
            name: f['name'],
            desc: f['description'],
            symbol: f['symbol'],
            total: double.parse(f['total_supply']),
            mintable: f['mintable'],
            owner: f['owner'],
          ));
        }
      });
    }
    if (dataList.isNotEmpty) {
      setState(() {
        _isEmpty = false;
      });
    }

    if (result == null || result.isEmpty || result.length < TOKEN_REQUEST_LIMIT) {
      setState(() {
        _isBottom = true;
      });
    } else {
      if (pageIndex == 1 && dataList.length < TOKEN_REQUEST_LIMIT) {
        pageIndex += 1;
        mPresenter.getIssueList(pageIndex, TOKEN_REQUEST_LIMIT);
      } else {
        setState(() {
          _isBottom = false;
          _isMore = false;
        });
      }
    }
  }

  @override
  void dismissLoading() {
    setState(() {});
  }

  @override
  void showLoading() {
    setState(() {});
  }

  @override
  void showMessage(String msg) {
    ToastUtils.show(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.MAIN_COLOR),
      appBar: AppBar(
        title: FixedSizeText(
          FlutterI18n.translate(context, 'issue.list'),
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
              navPush(context, IssueTokenPage(widget.wallet, symbols));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullToRefresh,
        child: _buildListView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    if (dataList == null) {
      mPresenter.getIssueList(pageIndex, TOKEN_REQUEST_LIMIT);
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
              style: TextStyle(color: Color(AppColors.GREY_1), fontSize: 12.0),
            )
          ],
        ),
      );
    }
    if (_isEmpty) {
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
                    style: TextStyle(fontSize: 12.0, color: Color(AppColors.GREY_2)),
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
      itemCount: dataList.length + 1,
      itemBuilder: (context, index) {
        if (index == dataList.length) {
          return _isBottom
              ? Container(
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
                )
              : _isMore
                  ? Container(
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
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Color(AppColors.COLOR_PRIMARY)),
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
                                    color: Color(AppColors.GREY_1),
                                  ),
                                )
                              ],
                            ),
                          )),
                    )
                  : Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          child: Container(
                            height: 60.0,
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: FixedSizeText(
                                FlutterI18n.translate(context, 'click_load_more'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(AppColors.GREY_1),
                                    fontSize: 12.0),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isMore = true;
                            });
                            pageIndex += 1;
                            mPresenter.getIssueList(
                                pageIndex, TOKEN_REQUEST_LIMIT);
                          },
                        ),
                      ),
                    );
        }
        return IssueTokenItem(
          wallet: widget.wallet,
          token: dataList[index],
          isLastone: index == dataList.length,
        );
      },
    );
  }
}
