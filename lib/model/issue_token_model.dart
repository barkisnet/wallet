///
/// 钱包对象
///

class IssueTokenModel {
  String name;
  String desc;
  String symbol;
  double total;
  bool mintable;
  String owner;

  IssueTokenModel(
      {this.name,
      this.desc,
      this.symbol,
      this.total,
      this.mintable,
      this.owner});
}
