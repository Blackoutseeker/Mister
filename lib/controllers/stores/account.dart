import 'package:mobx/mobx.dart';

import 'package:mister/models/interfaces/stores/account.dart';
import 'package:mister/models/database/account.dart';

part 'account.g.dart';

class AccountStore = AccountStoreBase with _$AccountStore;

abstract class AccountStoreBase with Store implements AccountStoreTemplate {
  @observable
  @override
  Account account = Account(null, null);

  @action
  @override
  Future<void> signIn(Account account) async {
    this.account = account;
  }

  @action
  @override
  Future<void> signOut() async {
    account = Account(null, null);
  }
}
