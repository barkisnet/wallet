import 'config.dart';

///
/// 配置工具类
///

class ChainParams {
  static const String ORGANIZATION = "Barkis";
  static const String ADDRESS_PREFIX = "barkis";
  static const String MAIN_TOKEN_DENOM = "ubarkis";
  static const String MAIN_TOKEN_SHORT_NAME = "BKS";
  static const String MAIN_TOKEN_FULL_NAME = "Barkis";
  static const int MAIN_TOKEN_UNIT = 1000000;

  static const int SUB_TOKEN_DECIMAL = 6;
  static const int SUB_TOKEN_UNIT = 1000000; //这个参数与SUB_TOKEN_DECIMAL联动，小数点的位数

  static const String SEND_GAS_WANTED = "100000";
  static const String SEND_DEFAULT_GAS_AMOUNT = "1000";
  static double DEFAULT_TX_NETWORK_FEE =
      (double.parse(SEND_DEFAULT_GAS_AMOUNT) / MAIN_TOKEN_UNIT);

  static const String DELEGATION_GAS_USED = "200000";
  static const String DELEGATION_DEFAULT_GAS_AMOUNT = "2000";
  static double DEFAULT_DELEGATION_NETWORK_FEE =
      (double.parse(DELEGATION_DEFAULT_GAS_AMOUNT) / MAIN_TOKEN_UNIT);

  static const String ISSUE_TOKEN_GAS_WANTED = "140000";
  static const String ISSUE_TOKEN_FEE = "2000";
  static const String MINT_TOKEN_FEE = "1000";

  static String get lcdUrl {
    switch (Config.env) {
      case Env.DEBUG:
        return "http://wallet-api-test.bksnet.io:1317";
      case Env.RELEASE:
        return "http://apibksnet.staticbks.top";
      default:
        return "http://apibksnet.staticbks.top";
    }
  }

  static String get chainID {
    switch (Config.env) {
      case Env.DEBUG:
        return "barkisnet-testnet";
      case Env.RELEASE:
        return "barkisnet";
      default:
        return "barkisnet";
    }
  }
}
