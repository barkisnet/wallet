import 'package:wallet/net/api_manager.dart';
import 'package:wallet/net/api_service.dart';

///
/// 收益与佣金接口
///

class DistributionRepository {

  ///
  /// 获取委托的所有收益
  ///
  void getRewardList(String delegatorAddress, ApiStateHook hook) {
    ApiManager.instance.get("/distribution/delegators/${delegatorAddress}/rewards", null, hook);
  }

  ///
  /// 获取委托人在某个验证人上的收益
  ///
  void getReward(String delegatorAddress, String valoperAddress, ApiStateHook hook) {
    ApiManager.instance.get("/distribution/delegators/${delegatorAddress}/rewards/${valoperAddress}", null, hook);
  }

  ///
  /// 根据验证人的地址，获取验证人的自委托收益与佣金
  ///
  void getRewardAndCommission(String valoperAddress, ApiStateHook hook) {
    ApiManager.instance.get("/distribution/validators/${valoperAddress}", null, hook);
  }
}
