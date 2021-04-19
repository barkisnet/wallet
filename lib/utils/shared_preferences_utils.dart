import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/model/wallet_model.dart';

import '../config.dart';

///
/// 本地数据缓存的工具类
///

class SPUtils {
  static const String SP_WALLET_NAME = 'wallet_name';
  static const String SP_WALLET_PASSWORD = 'wallet_password';
  static const String SP_WALLET_ADDRESS = 'wallet_address';
  static const String SP_WALLET_MNEMONIC = 'wallet_mnemonic';
  static const String SP_WALLET_SELECTED = 'wallet_selected';

  static const String SP_LANGUAGE_CODE = 'language_code';

  ///获取当前语言
  static Future<String> getLanguageCode() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String code = sp.getString(SP_LANGUAGE_CODE);
    if(code == null){
      code = Config.DEFAULT_LANGUAGE;
    }
    return code;
  }

  static Future<bool> setLanguageCode(String languageCode) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp..setString(SP_LANGUAGE_CODE, languageCode);
    return true;
  }

  static Future<bool> setWalletInfo(Map<String, dynamic> map) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp
      ..setString(SP_WALLET_NAME, map['name'])
      ..setString(SP_WALLET_PASSWORD, map['password'])
      ..setString(SP_WALLET_ADDRESS, map['address'])
      ..setString(SP_WALLET_MNEMONIC, map['mnemonic'])
      ..setBool(SP_WALLET_SELECTED, map['selected'] > 0);
    return true;
  }

  static Future<bool> setWalletModel(WalletModel wallet) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp
      ..setString(SP_WALLET_NAME, wallet.name)
      ..setString(SP_WALLET_PASSWORD, wallet.password)
      ..setString(SP_WALLET_ADDRESS, wallet.address)
      ..setString(SP_WALLET_MNEMONIC, wallet.mnemonic)
      ..setBool(SP_WALLET_SELECTED, wallet.selected);
    return true;
  }

  static Future<void> clearWalletInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp
      ..setString(SP_WALLET_NAME, '')
      ..setString(SP_WALLET_PASSWORD, '')
      ..setString(SP_WALLET_ADDRESS, '')
      ..setString(SP_WALLET_MNEMONIC, '')
      ..setBool(SP_WALLET_SELECTED, false);
  }

  ///获取钱包名称
  static Future<String> getWalletName() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_WALLET_NAME);
  }

  static Future<bool> setWalletName(String walletName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp..setString(SP_WALLET_NAME, walletName);
    return true;
  }

  ///获取钱包密码
  static Future<String> getPassword() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_WALLET_PASSWORD);
  }

  static Future<bool> setWalletPassword(String walletPassword) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp..setString(SP_WALLET_PASSWORD, walletPassword);
    return true;
  }

  ///获取钱包地址
  static Future<String> getWalletAddress() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_WALLET_ADDRESS);
  }

  ///获取助记词
  static Future<String> getWalletWords() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_WALLET_MNEMONIC);
  }

  ///获取是否默认的钱包
  static Future<bool> getWalletSelected() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(SP_WALLET_SELECTED);
  }

  ///获取钱包信息
  static Future<Map<String, dynamic>> getWalletInfoToMap() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, dynamic> map = Map<String, dynamic>();
    map[SP_WALLET_NAME] = sp.getString(SP_WALLET_NAME);
    map[SP_WALLET_PASSWORD] = sp.getString(SP_WALLET_PASSWORD);
    map[SP_WALLET_ADDRESS] = sp.getString(SP_WALLET_ADDRESS);
    map[SP_WALLET_MNEMONIC] = sp.getString(SP_WALLET_MNEMONIC);
    map[SP_WALLET_SELECTED] = sp.getBool(SP_WALLET_SELECTED);
    return map;
  }

  ///获取钱包信息
  static Future<WalletModel> getWalletInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    WalletModel model = WalletModel();
    model.name = sp.getString(SP_WALLET_NAME);
    model.password = sp.getString(SP_WALLET_PASSWORD);
    model.address = sp.getString(SP_WALLET_ADDRESS);
    model.mnemonic = sp.getString(SP_WALLET_MNEMONIC);
    model.selected = sp.getBool(SP_WALLET_SELECTED);
    return model;
  }
}
