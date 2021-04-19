///
/// Token
///

class TokenItemModel {
  String symbol;
  double amount;
  String name;
  double delegationAmount = 0;

  TokenItemModel(
      {this.symbol,
      this.amount = 0,
      this.name,
      this.delegationAmount = 0});
}
