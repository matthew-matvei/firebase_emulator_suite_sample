import 'package:firebase_emulator_suite_sample/todo_item_store.dart';
import 'package:firebase_emulator_suite_sample/user.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common_finders_extensions.dart';
import 'test_runner_extensions.dart';

void main() {
  testWidgets(
    "The user only sees todo items created by their organisation",
    (tester) async {
      final todoItemStore = InMemoryTodoItemStore();
      await tester.runApp(store: todoItemStore);

      const bobTodo = "Bob's organisation's todo list item";
      await tester.createTodoAs(TestUsers.bob, bobTodo);

      await tester.restartAndRestore();

      const jillTodo = "Jill's todo list is for a different organisation";
      await tester.createTodoAs(TestUsers.jill, jillTodo);

      await tester.restartAndRestore();

      const bobColleagueTodo = "Bob's colleague's todo list item";
      await tester.createTodoAs(TestUsers.bobsColleague, bobColleagueTodo);

      await tester.restartAndRestore();
      await tester.loginAs(TestUsers.bob);

      expect(find.text(bobTodo), findsOneWidget);
      expect(find.text(bobColleagueTodo), findsOneWidget);
      expect(find.text(jillTodo), findsNothing);
    },
  );

  testWidgets("The user can only delete a todo item they themselves created",
      (tester) async {
    await tester.runApp();

    const bobTodo = "This is Bob's Todo, hands off!";
    await tester.createTodoAs(TestUsers.bob, bobTodo);

    await tester.restartAndRestore();

    const bobsColleagueTodo = "This is Bob's colleague's lovely todo";
    await tester.createTodoAs(TestUsers.bobsColleague, bobsColleagueTodo);

    expect(find.text(bobTodo), findsOneWidget);
    expect(find.text(bobsColleagueTodo), findsOneWidget);

    await tester.deleteTodoListItems([bobTodo, bobsColleagueTodo]);

    expect(
      find.text("Sorry, you can only delete your own todo items!"),
      findsOneWidget,
    );

    await tester.tap(find.text("Close"));
    await tester.pumpAndSettle();

    expect(find.text(bobTodo), findsOneWidget);
    expect(find.text(bobsColleagueTodo), findsOneWidget);
  });

  testWidgets(
    "The user can complete / uncomplete any todo item in their organisation",
    (tester) async {
      await tester.runApp();

      const bobTodo = "This is Bob's Todo, hands off!";
      await tester.createTodoAs(TestUsers.bob, bobTodo);

      await tester.restartAndRestore();

      const bobsColleagueTodo = "This is Bob's colleague's lovely todo";
      await tester.createTodoAs(TestUsers.bobsColleague, bobsColleagueTodo);

      expect(find.completedTodoListItem(bobTodo), findsOneWidget);
      expect(find.completedTodoListItem(bobsColleagueTodo), findsOneWidget);
    },
  );
}

extension _CreatingTodosAsUser on WidgetTester {
  Future<void> createTodoAs(UserCredentials user, String todo) async {
    await loginAs(user);
    await createTodoListItem(todo);
  }
}
