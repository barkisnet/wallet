import 'package:wallet/net/api_manager.dart';
import 'package:wallet/net/api_service.dart';

///
/// 交易接口
///

class TransactionRepository {

  ///
  /// 获取一条交易
  ///
  void getTx(String hash, ApiStateHook hook) {
    ApiManager.instance.get("/txs/$hash", null, hook);
  }

  ///
  /// 查询参数地址的转出交易记录
  ///
  void getOutTxList(String fromAddress, int page, int limit, ApiStateHook hook) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['message.action'] = "send";
    params['message.sender'] = fromAddress;
    params['page'] = page;
    params['limit'] = limit;
    ApiManager.instance.get("/txs", params, hook);
  }

  ///
  /// 查询参数地址的转入交易记录
  ///
  void getInTxList(String toAddress, int page, int limit, ApiStateHook hook) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['message.action'] = "send";
    params['transfer.recipient'] = toAddress;
    params['page'] = page;
    params['limit'] = limit;
    ApiManager.instance.get("/txs", params, hook);
  }

  ///
  /// 根据委托人的地址，查询委托、赎回、领取收益、领取佣金记录
  ///
  void getDelegationList(String msgType, String delegatorAddress, int page, int limit, ApiStateHook hook) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params['message.action'] = msgType;
    params['message.sender'] = delegatorAddress;
    params['page'] = page;
    params['limit'] = limit;
    ApiManager.instance.get("/txs", params, hook);
  }
}
