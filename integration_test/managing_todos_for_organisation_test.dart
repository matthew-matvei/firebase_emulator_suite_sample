import 'package:firebase_emulator_suite_sample/user.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_runner_extensions.dart';

void main() {
  testWidgets(
    "The user only sees todo items created by their organisation",
    (tester) async {
      await tester.runApp();
      await tester.loginAs(TestUsers.bob);

      var bobTodo = "Bob's organisation's todo list item";
      await tester.createTodoListItem(bobTodo);

      await tester.restartAndRestore();
      await tester.loginAs(TestUsers.jill);

      var jillTodo = "Jill's todo list is for a different organisation";
      await tester.createTodoListItem(jillTodo);

      await tester.restartAndRestore();
      await tester.loginAs(TestUsers.bobsColleague);

      var bobColleagueTodo = "Bob's colleague's todo list item";
      await tester.createTodoListItem(bobColleagueTodo);

      await tester.restartAndRestore();
      await tester.loginAs(TestUsers.bob);

      expect(find.text(bobTodo), findsOneWidget);
      expect(find.text(bobColleagueTodo), findsOneWidget);
      expect(find.text(jillTodo), findsNothing);
    },
  );

  testWidgets("The user can only delete a todo item they themselves created",
      (tester) async {
    throw UnimplementedError();
  });

  testWidgets(
    "The user can complete / uncomplete any todo item in their organisation",
    (tester) async {
      throw UnimplementedError();
    },
  );
}
