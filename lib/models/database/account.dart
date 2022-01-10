class Account {
  Account(this.id, this.profession);

  String? id;
  String? profession;

  factory Account.convertFromDatabase(String id, Map<dynamic, dynamic> data) {
    return Account(id, data['profession']);
  }
}
