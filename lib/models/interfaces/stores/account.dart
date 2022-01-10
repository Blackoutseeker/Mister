import 'package:mister/models/database/account.dart';

abstract class AccountStoreTemplate {
  Account account = Account(null, null);

  Future<void> signIn(Account account);
  Future<void> signOut();
}
