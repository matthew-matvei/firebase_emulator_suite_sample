import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integration_test/integration_test.dart';
import 'login_test.dart' as login;
import 'managing_todos_test.dart' as managing_todos;
import 'managing_todos_for_organisation_test.dart'
    as managing_todos_for_organisation;
import 'test_user.dart';
import 'package:firebase_emulator_suite_sample/main.dart' as app
    show initialise;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await app.initialise();

  await _deleteAllTodos();
  await _seedTestUsers();

  login.main();
  managing_todos.main();
  managing_todos_for_organisation.main();
}

Future<void> _deleteAllTodos() async {
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

Future<void> _seedTestUsers() async {
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
