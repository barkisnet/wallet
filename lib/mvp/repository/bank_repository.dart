import 'package:wallet/net/api_manager.dart';
import 'package:wallet/net/api_service.dart';

///
/// 账户接口，比如获取余额
///

class BankRepository {
  void getBalance(String address, ApiStateHook hook) {
    ApiManager.instance.get("/bank/balances/$address", null, hook);
  }
}
