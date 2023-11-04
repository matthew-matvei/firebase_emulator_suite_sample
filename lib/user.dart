class User {
  final String userName;
  final String organisation;
  User({required this.userName, required this.organisation});
}

class UserCredentials extends User {
  final String password;

  UserCredentials(
      {required super.userName,
      required this.password,
      required super.organisation});

  @override
  operator ==(other) =>
      other is UserCredentials &&
      userName == other.userName &&
      password == other.password;

  @override
  int get hashCode => Object.hash(userName, password);
}
