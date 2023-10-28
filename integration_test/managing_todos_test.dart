import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_emulator_suite_sample/main.dart' as app hide AppKeys;

void main() {
  testWidgets("The user sees a list of todo items", (tester) async {
    await tester.runApp();

    expect(find.text("Todos"), findsOneWidget);
    expect(find.byKey(AppKeys.todoList), findsOneWidget);
  });

  testWidgets("The user can create new todo list items", (tester) async {
    await tester.runApp();

    await tester.createTodoListItem("My todo item");
    await tester.createTodoListItem("Another todo item");
    await tester.createTodoListItem("I'm getting bored now");

    expect(find.text("My todo item"), findsOneWidget);
    expect(find.text("Another todo item"), findsOneWidget);
    expect(find.text("I'm getting bored now"), findsOneWidget);
  });
}

extension _TestRunner on WidgetTester {
  Future<void> runApp() async {
    app.main();
    await pumpAndSettle();
  }

  Future<void> createTodoListItem(String name) async {
    await tap(find.byKey(AppKeys.createNewTodo));
    await pumpAndSettle();
    await enterText(find.byKey(AppKeys.newTodoText), name);
    await testTextInput.receiveAction(TextInputAction.done);
    await pumpAndSettle();
  }
}
