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

  try {
    for (var user in TestUsers.all) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.userName,
        password: user.password,
      );
    }
  } on FirebaseAuthException catch (ex) {
    if (ex.code != "email-already-in-use") {
      rethrow;
    }
  }

  login.main();
  managing_todos.main();
  managing_todos_for_organisation.main();
}
