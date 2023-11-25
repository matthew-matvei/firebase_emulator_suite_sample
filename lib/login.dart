import 'package:firebase_auth/firebase_auth.dart' hide User;
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
                onPressed: _tryAuthenticateUser,
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

  Future<void> _tryAuthenticateUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userNameController.text, password: _passwordController.text);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(Routes.todos);
    } on FirebaseAuthException {
      setState(() {
        _invalidCredentialsReceived = true;
      });
    }
  }
}
