import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;

import 'login_test.dart' as login;
import 'managing_todos_test.dart' as managing_todos;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "any",
          appId: "firebase_emulator_suite_sample",
          messagingSenderId: "any",
          projectId: "demo-firebase-emulator-suite"));

  FirebaseAuth.instance.useAuthEmulator("localhost", 9099);

  final response = await http.post(
      Uri.http("10.0.2.2:9099",
          "/identitytoolkit.googleapis.com/v1/accounts:signUp", {"key": "any"}),
      body: jsonEncode({
        "email": "admin@fake.com",
        "password": "Guest1!",
        "returnSecureToken": "true"
      }),
      headers: {"Content-Type": "application/json"},
      encoding: utf8);

  if (response.statusCode != 200 && response.statusCode != 400) {
    throw StateError(
      "Received unexpected status code when signing up test user: ${response.statusCode} ${response.body}",
    );
  }

  if (response.statusCode == 400 && !response.body.contains("EMAIL_EXISTS")) {
    throw StateError(
      "Received unexpected error when signing up test user: '${response.body}'",
    );
  }

  /*try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: "admin", password: "Guest1!");
  } on FirebaseAuthException catch (ex) {
    if (ex.code != "email-already-in-use") {
      rethrow;
    }
  }*/

  login.main();
  managing_todos.main();
}
