import 'package:bech32/bech32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:sacco/sacco.dart';
import 'package:wallet/chain_params.dart';

final networkInfo = NetworkInfo(
  bech32Hrp: ChainParams.ADDRESS_PREFIX,
  lcdUrl: ChainParams.lcdUrl,
);

/// 产生助记词，创建钱包时使用
String generateMnemonic() {
  String randomMnemonic = bip39.generateMnemonic(strength:128);
  return randomMnemonic;
}

/// 判断助记词是否正确，单词之间有多个空格对的
bool validateMnemonic(String mnemonic) {
  RegExp exp = new RegExp(r"(\s+)");
  var mnemonicStr = mnemonic.replaceAll(exp, " ");
  bool isValid = bip39.validateMnemonic(mnemonicStr);
  return isValid;
}

/// 判断地址格式是否正确
bool isValidAddress(String address) {
  if (!address.startsWith(ChainParams.ADDRESS_PREFIX)) {
    return false;
  }
  bool isValid = true;
  Bech32Codec codec = Bech32Codec();
  try {
    codec.decode(address);
  } catch(e) {
    isValid = false;
  }
  return isValid;
}

/// 创建钱包对象，导入或者创建钱包时使用，用来获取bech32Address地址
Wallet createWallet(String mnemonic) {
  RegExp exp = new RegExp(r"(\s+)");
  final mnemonicList = mnemonic.split(exp);
  final wallet = Wallet.derive(mnemonicList, networkInfo);
  return wallet;
}

/// 把钱包地址转换为验证人的操作地址
String convertWalletAddressToValoperAddress(String walletAddress) {
  final bech32Codec = Bech32Codec();
  final bech32Data = bech32Codec.decode(walletAddress).data;

  String addressPrefix = ChainParams.ADDRESS_PREFIX + "valoper";
  final bech32Data2 = Bech32(addressPrefix, bech32Data);

  var valoperAddress = bech32Codec.encode(bech32Data2);
  return valoperAddress;
}

/// 把验证人的操作地址转换为钱包地址
String convertValoperAddressToWalletAddress(String valoperAddress) {
  final bech32Codec = Bech32Codec();
  final bech32Data = bech32Codec.decode(valoperAddress).data;

  String addressPrefix = ChainParams.ADDRESS_PREFIX;
  final bech32Data2 = Bech32(addressPrefix, bech32Data);

  var walletAddress = bech32Codec.encode(bech32Data2);
  return walletAddress;
}
