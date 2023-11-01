import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:firebase_emulator_suite_sample/user.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final CurrentSession _session;
  const Login({super.key, required CurrentSession session})
      : _session = session;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _invalidCredentialsReceived = false;
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log in")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: Form(
                child: Column(
          children: [
            TextFormField(
              key: AppKeys.userNameText,
              decoration: const InputDecoration(label: Text("Username:")),
              controller: _userNameController,
            ),
            TextFormField(
              key: AppKeys.passwordText,
              decoration: const InputDecoration(label: Text("Password")),
              obscureText: true,
              controller: _passwordController,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                key: AppKeys.login,
                onPressed: () {
                  final recognisedUserCredentials = _validUserCredentials()
                      .where((credentials) =>
                          credentials.userName == _userNameController.text &&
                          credentials.password == _passwordController.text)
                      .firstOrNull;

                  if (recognisedUserCredentials != null) {
                    widget._session.user = _testUserWithCredentialsMatching(
                        recognisedUserCredentials);
                    Navigator.of(context).pushReplacementNamed(Routes.todos);
                    return;
                  }

                  setState(() {
                    _invalidCredentialsReceived = true;
                  });
                },
                child: const Text("Submit"),
              ),
            ),
            if (_invalidCredentialsReceived)
              const Text(
                "Invalid username or password",
                style: TextStyle(color: Colors.red),
              )
          ],
        ))),
      ),
    );
  }

  User? _testUserWithCredentialsMatching(
          UserCredentials recognisedUserCredentials) =>
      [TestUsers.admin, TestUsers.bob, TestUsers.bobsColleague, TestUsers.jill]
          .firstWhere((credential) =>
              recognisedUserCredentials.userName == credential.userName &&
              recognisedUserCredentials.password == credential.password);
}

Set<UserCredentials> _validUserCredentials() =>
    {TestUsers.bob, TestUsers.bobsColleague, TestUsers.jill, TestUsers.admin};
