class User {
  final String userName;
  User({required this.userName});
}

class UserCredentials extends User {
  final String password;

  UserCredentials({required super.userName, required this.password});

  @override
  operator ==(other) =>
      other is UserCredentials &&
      userName == other.userName &&
      password == other.password;

  @override
  int get hashCode => Object.hash(userName, password);
}

class TestUsers {
  static final UserCredentials bob =
      UserCredentials(userName: "bob@gmail.com", password: "C4n w3 f1x 1t?");

  static UserCredentials bobsColleague =
      UserCredentials(userName: "bill@gmail.com", password: "B0b l0bl4w.");

  static final UserCredentials jill =
      UserCredentials(userName: "jill@hotmail.com", password: "Y3s w3 c4n!");

  static final UserCredentials admin =
      UserCredentials(userName: "admin", password: "Guest1!");

  TestUsers._();
}
