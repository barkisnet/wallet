///
/// 钱包对象
///

class WalletModel {
  String name;
  String address;
  String mnemonic;
  String password;
  bool selected;
  int createTime;

  double balance = 0;

  WalletModel(
      {this.name = "",
      this.address = "",
      this.mnemonic,
      this.password,
      this.selected,
      this.createTime,
      this.balance = 0});
}
