import 'package:flutter_test/flutter_test.dart';

import 'test_runner_extensions.dart';

void main() {
  testWidgets("The user is first greeted with a login page", (tester) async {
    await tester.runApp();

    expect(find.text("Log in"), findsOneWidget);
  });

  testWidgets(
    "The user is refused if they provide invalid credentials",
    (tester) async {
      await tester.runApp();
      await tester.login(userName: "Something", password: "Incorrect");

      expect(find.text("Invalid username or password"), findsOneWidget);
    },
  );

  testWidgets("The user is shown a todo list if they provide valid credentials",
      (tester) async {
    await tester.runApp();
    await tester.login();

    expect(find.text("Invalid username or password"), findsNothing);
    expect(find.text("Log in"), findsNothing);
    expect(find.text("Todos"), findsOneWidget);
  });
}
