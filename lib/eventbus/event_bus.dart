import 'package:event_bus/event_bus.dart';
import 'package:wallet/model/contact_model.dart';
import 'package:wallet/model/wallet_model.dart';

///
/// 函数回调监听
///

EventBus eventBus = EventBus();

class OpenEndDrawer{}

class ChangeMainPage{}

class WalletChangeListener{
  String address;
  WalletChangeListener({this.address});
}

class WalletChangeSuccess{
  WalletModel model;

  WalletChangeSuccess({this.model});
}

class WalletModifyNameListener{
  String address;
  String walletName;
  WalletModifyNameListener({this.address, this.walletName});
}

class WalletDeleteListener{
  WalletModel model;
  WalletDeleteListener({this.model});
}

class WalletModifyPasswordListener{
  String address;
  String password;
  WalletModifyPasswordListener({this.address, this.password});
}

///联系人
class ContactUpdateSuccess{}

class ContactSelectedItem{
  ContactModel contact;
  ContactSelectedItem({this.contact});
}
