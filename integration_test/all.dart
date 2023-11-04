import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_emulator_suite_sample/user.dart';
import 'package:integration_test/integration_test.dart';
import 'login_test.dart' as login;
import 'managing_todos_test.dart' as managing_todos;
import 'managing_todos_for_organisation_test.dart'
    as managing_todos_for_organisation;
import 'test_user.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "any",
          appId: "firebase_emulator_suite_sample",
          messagingSenderId: "any",
          projectId: "demo-firebase-emulator-suite"));

  FirebaseAuth.instance.useAuthEmulator("localhost", 9099);

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
