import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
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
                onPressed: () async {
                  try {
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _userNameController.text,
                            password: _passwordController.text);

                    final userInfo = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(userCredential.user!.email)
                        .get()
                        .then((value) => value.data());

                    if (userInfo == null) {
                      throw StateError(
                          "Failed to find information for user with email ${userCredential.user!.email}");
                    }

                    widget._session.user = User(
                        userName: userCredential.user!.email!,
                        organisation: userInfo['organisation'] as String);

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.of(context).pushReplacementNamed(Routes.todos);
                  } on FirebaseAuthException {
                    setState(() {
                      _invalidCredentialsReceived = true;
                    });
                  }
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
}
