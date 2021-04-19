import 'package:wallet/model/validator_model.dart';

///
/// 委托 对象
///

class DelegationModel {
  ValidatorModel validator;
  String validatorName;
  String validatorAddress;
  double delegationAmount = 0;
  double rewardAmount = 0;

  DelegationModel(
      {this.validator,
      this.validatorName,
      this.validatorAddress,
      this.delegationAmount = 0,
      this.rewardAmount = 0});
}
