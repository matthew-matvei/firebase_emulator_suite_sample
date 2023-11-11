import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_user.dart';

Future<void> deleteAllTodos() async {
  final batch = FirebaseFirestore.instance.batch();

  final todos = await FirebaseFirestore.instance
      .collection("todos")
      .get()
      .then((value) => value.docs);

  for (final todo in todos) {
    batch.delete(todo.reference);
  }

  await batch.commit();
}

Future<void> seedTestUsers() async {
  try {
    for (var user in TestUsers.all) {
      final newUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.userName,
        password: user.password,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(newUser.user!.uid)
          .set({"organisation": user.organisation});
    }
  } on FirebaseAuthException catch (ex) {
    if (ex.code != "email-already-in-use") {
      rethrow;
    }
  }
}
