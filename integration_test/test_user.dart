import 'package:firebase_emulator_suite_sample/user.dart';

class TestUsers {
  static final UserCredentials bob = UserCredentials(
      userName: "bob@gmail.com",
      password: "C4n w3 f1x 1t?",
      organisation: "Bob's Buildings");

  static UserCredentials bobsColleague = UserCredentials(
      userName: "bill@gmail.com",
      password: "B0b l0bl4w.",
      organisation: "Bob's Buildings");

  static final UserCredentials jill = UserCredentials(
      userName: "jill@hotmail.com",
      password: "Y3s w3 c4n!",
      organisation: "Jill's Javelins");

  static final UserCredentials admin = UserCredentials(
      userName: "admin@system.com",
      password: "Guest1!",
      organisation: "The system");

  TestUsers._();

  static Iterable<UserCredentials> get all sync* {
    yield bob;
    yield bobsColleague;
    yield jill;
    yield admin;
  }
}
