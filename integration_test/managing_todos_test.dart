import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:flutter/material.dart';
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

  testWidgets("The user can rename todo list items", (tester) async {
    await tester.runApp();

    const initialTodoName = "Initial todo item name";
    const newTodoName = "New todo item name";
    await tester.createTodoListItem(initialTodoName);

    expect(
      find.text(initialTodoName),
      findsOneWidget,
      reason: "because the todo list item's name should not yet been updated",
    );
    expect(
      find.text(newTodoName),
      findsNothing,
      reason: "because the todo list item's name should not yet been updated",
    );

    await tester.updateTodoListItem(initialTodoName, newTodoName);

    expect(
      find.text(initialTodoName),
      findsNothing,
      reason: "because the todo list item's name should have now been updated",
    );
    expect(
      find.text(newTodoName),
      findsOneWidget,
      reason: "because the todo list item's name should have now been updated",
    );
  });

  testWidgets("The user can delete multiple todo list items", (tester) async {
    await tester.runApp();

    const firstTodoListItem = "First to be deleted";
    const safeTodoListItem = "Item that won't be deleted";
    const secondTodoListItem = "Second to be deleted";

    await tester.createTodoListItem(firstTodoListItem);
    await tester.createTodoListItem(safeTodoListItem);
    await tester.createTodoListItem(secondTodoListItem);

    await tester.deleteTodoListItems([firstTodoListItem, secondTodoListItem]);

    expect(find.text(firstTodoListItem), findsNothing);
    expect(find.text(safeTodoListItem), findsOneWidget);
    expect(find.text(secondTodoListItem), findsNothing);
  });

  testWidgets("The user can mark todo list items complete", (tester) async {
    await tester.runApp();

    const firstTodoListItem = "First to be completed";
    const incompleteTodoListItem = "Item that won't be completed";
    const secondTodoListItem = "Second to be completed";

    await tester.createTodoListItem(firstTodoListItem);
    await tester.createTodoListItem(incompleteTodoListItem);
    await tester.createTodoListItem(secondTodoListItem);

    await tester.completeTodoListItems([firstTodoListItem, secondTodoListItem]);

    final completed = find.byKey(AppKeys.completedTodoList);
    expect(completed, findsOneWidget);
    expect(
      find.descendant(of: completed, matching: find.text(firstTodoListItem)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: completed, matching: find.text(secondTodoListItem)),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: completed, matching: find.text(incompleteTodoListItem)),
      findsNothing,
    );
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

  Future<void> updateTodoListItem(String initialName, String newName) async {
    await tap(find.text(initialName));
    await pumpAndSettle();
    await enterText(find.text(initialName), newName);
    await testTextInput.receiveAction(TextInputAction.done);
    await pumpAndSettle();
  }

  Future<void> deleteTodoListItems(List<String> todoListItems) async {
    for (final todoListItem in todoListItems) {
      final row = find.ancestor(
          of: find.text(todoListItem), matching: find.byType(Row));
      final checkbox =
          find.descendant(of: row, matching: find.byType(Checkbox));
      await tap(checkbox);
      await pumpAndSettle();
    }

    await tap(find.byKey(AppKeys.bulkDelete));
    await pumpAndSettle();
  }

  Future<void> completeTodoListItems(List<String> todoListItems) async {
    for (final todoListItem in todoListItems) {
      final row = find.ancestor(
          of: find.text(todoListItem), matching: find.byType(Row));
      final checkbox =
          find.descendant(of: row, matching: find.byType(Checkbox));
      await tap(checkbox);
      await pumpAndSettle();
    }

    await tap(find.byKey(AppKeys.bulkComplete));
    await pumpAndSettle();
  }
}
