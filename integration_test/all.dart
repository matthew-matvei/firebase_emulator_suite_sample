import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_user.dart';
import 'package:http/http.dart' as http;

Future<void> deleteTestData() async {
  final deleteUri = Uri.http("10.0.2.2:8080",
      "emulator/v1/projects/demo-firebase-emulator-suite/databases/(default)/documents");
  final response = await http.delete(deleteUri);

  if (response.statusCode >= 300) {
    throw HttpException("Failed with status code ${response.statusCode}",
        uri: deleteUri);
  }
}

Future<void> seedTestUsers() async {
  for (var user in TestUsers.all) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.userName,
        password: user.password,
      );
    } on FirebaseAuthException catch (ex) {
      if (ex.code != "email-already-in-use") {
        rethrow;
      }
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.userName)
        .set({"organisation": user.organisation});
  }
}
