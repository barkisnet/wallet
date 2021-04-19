import 'package:sacco/sacco.dart';
import 'package:wallet/chain_params.dart';
import 'package:wallet/crypto/wallet_key.dart';

///
/// 发送交易的接口
///
class TxService {

  static final String MSG_TYPE_SEND = "cosmos-sdk/MsgSend";
  static final String MSG_TYPE_DELEGATE = "cosmos-sdk/MsgDelegate";
  static final String MSG_TYPE_UNDELEGATE = "cosmos-sdk/MsgUndelegate";
  static final String MSG_TYPE_WITHDRAW_REWARD = "cosmos-sdk/MsgWithdrawDelegationReward";
  static final String MSG_TYPE_WITHDRAW_COMMISSION = "cosmos-sdk/MsgWithdrawValidatorCommission";
  static final String MSG_ISSUE_TOKEN = "cosmos-sdk/IssueMsg";
  static final String MSG_MINT_TOKEN = "cosmos-sdk/MintMsg";

  /// 转账
  static Future<TransactionResult> send(String denom, String mnemonic, String toAddress, double amount, double gasAmount, String memo) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: MSG_TYPE_SEND,
      value: {
        "from_address": wallet.bech32Address,
        "to_address": toAddress,
        "amount": [
          {"denom": denom, "amount": (amount * (denom == ChainParams.MAIN_TOKEN_DENOM ? ChainParams.MAIN_TOKEN_UNIT : ChainParams.SUB_TOKEN_UNIT)).toStringAsFixed(0)}
        ]
      },
    );
    String ga = (gasAmount * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.SEND_GAS_WANTED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: memo);

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }

  /// 委托
  static Future<TransactionResult> delegate(String mnemonic, String validatorAddress, double amount, double gasAmount, String memo) async {
    return delegateOrUndelegate(MSG_TYPE_DELEGATE, mnemonic, validatorAddress, amount, gasAmount, memo);
  }

  /// 赎回
  static Future<TransactionResult> undelegate(String mnemonic, String validatorAddress, double amount, double gasAmount, String memo) async {
    return delegateOrUndelegate(MSG_TYPE_UNDELEGATE, mnemonic, validatorAddress, amount, gasAmount, memo);
  }

  /// 委托与赎回的消息结构类似，所以可以何用一个处理方法
  static Future<TransactionResult> delegateOrUndelegate(String msgType, String mnemonic, String validatorAddress, double amount, double gasAmount, String memo) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: msgType,
      value: {
        "delegator_address": wallet.bech32Address,
        "validator_address": validatorAddress,
        "amount": {"denom": ChainParams.MAIN_TOKEN_DENOM, "amount": (amount * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0)}
      },
    );
    String ga = (gasAmount * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.DELEGATION_GAS_USED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: memo);

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }

  /// 领取收益
  static Future<TransactionResult> withdrawReward(String mnemonic, String validatorAddress, double gasAmount, String memo) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: MSG_TYPE_WITHDRAW_REWARD,
      value: {
        "delegator_address": wallet.bech32Address,
        "validator_address": validatorAddress
      },
    );
    String ga = (gasAmount * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.DELEGATION_GAS_USED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: memo);

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }

  /// 领取佣金
  static Future<TransactionResult> withdrawCommission(String mnemonic, String validatorOperatorAddress, double gasAmount, String memo) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: MSG_TYPE_WITHDRAW_COMMISSION,
      value: {
        "validator_address": validatorOperatorAddress
      },
    );
    String ga = (gasAmount * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.DELEGATION_GAS_USED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: memo);

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }

  /// 发行通证
  static Future<TransactionResult> issueToken(String mnemonic, String name, String symbol, String totalSupply, bool mintable, String description) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: MSG_ISSUE_TOKEN,
      value: {
        "from": wallet.bech32Address,
        "name": name,
        "symbol": symbol,
        "total_supply": totalSupply + ("0"*ChainParams.SUB_TOKEN_DECIMAL),
        "mintable": mintable,
        "decimal": ChainParams.SUB_TOKEN_DECIMAL,
        "description": description
      },
    );
    String ga = (0.01 * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.ISSUE_TOKEN_GAS_WANTED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: "issue token $symbol");

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }

  /// 增发通证
  static Future<TransactionResult> mintToken(String mnemonic, String symbol, String amount) async {
    // 1.Creating a wallet
    Wallet wallet = createWallet(mnemonic);

    // 2.Creating a transaction
    final message = StdMsg(
      type: MSG_MINT_TOKEN,
      value: {
        "from": wallet.bech32Address,
        "symbol": symbol,
        "amount": amount + ("0"*ChainParams.SUB_TOKEN_DECIMAL)
      },
    );
    String ga = (0.01 * ChainParams.MAIN_TOKEN_UNIT).toStringAsFixed(0);
    StdFee fee = StdFee(gas: ChainParams.ISSUE_TOKEN_GAS_WANTED, amount: [StdCoin(amount: ga, denom: ChainParams.MAIN_TOKEN_DENOM)]);
    final stdTx = TxBuilder.buildStdTx(stdMsgs: [message], fee: fee, memo: "mint token $symbol");

    // 3.Signing a transaction
    final signedStdTx = await TxSigner.signStdTx(wallet: wallet, stdTx: stdTx);

    // 4.Sending a transaction
    try {
      final hash = await TxSender.broadcastStdTx(wallet: wallet, stdTx: signedStdTx);
      print("Tx send successfully. Hash: ${hash.toJson()}");
      return hash;
    } catch (error) {
      print("Error while sending the tx: $error");
    }
  }
}
