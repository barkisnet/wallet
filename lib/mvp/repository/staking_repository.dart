import 'package:wallet/net/api_manager.dart';
import 'package:wallet/net/api_service.dart';

///
/// 委托与赎回接口
///

class StakingRepository {

  ///
  /// 获取委托人的所有委托
  ///
  void getDelegationList(String delegatorAddress, ApiStateHook hook) {
    ApiManager.instance.get("/staking/delegators/$delegatorAddress/delegations", null, hook);
  }

  ///
  /// 获取委托人在验证人的委托记录
  ///
  void getDelegation(String delegatorAddress, String valoperAddress, ApiStateHook hook) {
    ApiManager.instance.get("/staking/delegators/$delegatorAddress/delegations/$valoperAddress", null, hook);
  }

  ///
  /// 获取委托人的所有赎回
  ///
  void getUndelegationList(String delegatorAddress, ApiStateHook hook) {
    ApiManager.instance.get("/staking/delegators/${delegatorAddress}/unbonding_delegations", null, hook);
  }

  ///
  /// 获取委托人在某个验证人上的赎回
  ///
  void getUndelegation(String delegatorAddress, String valoperAddress, ApiStateHook hook) {
    ApiManager.instance.get("/staking/delegators/${delegatorAddress}/unbonding_delegations/${valoperAddress}", null, hook);
  }

  ///
  /// 获取验证人列表
  ///
  void getValidatorList(String status, int pageIndex, int limit, ApiStateHook hook) {
    var params = Map<String, dynamic>();
    params["status"] = status;
    params["page"] = pageIndex;
    params["limit"] = limit;
    ApiManager.instance.get("/staking/validators", params, hook);
  }

  ///
  /// 获取一个验证人
  ///
  void getValidator(String valoperAddress, ApiStateHook hook) {
    ApiManager.instance.get("/staking/validators/${valoperAddress}", null, hook);
  }

}
