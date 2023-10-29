import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

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
      body: Center(
          child: Form(
              child: Column(
        children: [
          TextFormField(
            key: AppKeys.userNameText,
            controller: _userNameController,
          ),
          TextFormField(
            key: AppKeys.passwordText,
            controller: _passwordController,
          ),
          ElevatedButton(
            key: AppKeys.login,
            onPressed: () {
              if (_validCredentials().contains(
                  (_userNameController.text, _passwordController.text))) {
                Navigator.of(context).pushNamed(Routes.todos);
                return;
              }

              setState(() {
                _invalidCredentialsReceived = true;
              });
            },
            child: const Text("Submit"),
          ),
          if (_invalidCredentialsReceived)
            const Text("Invalid username or password")
        ],
      ))),
    );
  }
}

List<(String, String)> _validCredentials() => [("admin", "Guest1!")];
