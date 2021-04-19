import 'package:wallet/net/api_manager.dart';
import 'package:wallet/net/api_service.dart';

///
/// 获取自定义Token列表的接口
///

class AssetRepository {
  void getAssetList(Map<String, dynamic> params, ApiStateHook hook) {
    ApiManager.instance.get("/asset/list", params, hook);
  }
}
