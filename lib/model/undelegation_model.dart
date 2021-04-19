import 'package:wallet/model/validator_model.dart';

///
/// 赎回 对象
///

class UndelegationModel {
  ValidatorModel validator;
  String validatorName;
  String validatorAddress;
  double undelegationAmount = 0;
  String completeDatetime;

  UndelegationModel(
      {this.validatorName,
      this.validatorAddress,
      this.undelegationAmount = 0,
      this.completeDatetime});
}
