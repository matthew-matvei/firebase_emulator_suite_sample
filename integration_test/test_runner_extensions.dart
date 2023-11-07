import 'dart:async';

import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:firebase_emulator_suite_sample/todo_item_store.dart';
import 'package:firebase_emulator_suite_sample/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_user.dart';

extension TestRunner on WidgetTester {
  Future<void> runApp() async {
    final currentSession = CurrentSession();
    await pumpWidget(
      RootRestorationScope(
        restorationId: "Restore from start",
        child: TodoListApp(
          store: FirestoreTodoItemStore(session: currentSession),
          session: currentSession,
        ),
      ),
    );
    await pumpAndSettle();
  }

  Future<void> login({String? userName, String? password}) async {
    final validUserCredentials = TestUsers.admin;

    await enterText(
      find.byKey(AppKeys.userNameText),
      userName ?? validUserCredentials.userName,
    );
    await enterText(
      find.byKey(AppKeys.passwordText),
      password ?? validUserCredentials.password,
    );
    await tap(find.byKey(AppKeys.login));
    await _waitUntilGone(find.byKey(AppKeys.login));
  }

  Future<void> loginAs(UserCredentials user) async =>
      login(userName: user.userName, password: user.password);

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
    await _selectTodoListItems(todoListItems);

    await tap(find.byKey(AppKeys.bulkDelete));
    await pumpAndSettle();
  }

  Future<void> completeTodoListItems(List<String> todoListItems) async {
    await _selectTodoListItems(todoListItems);

    await tap(find.byKey(AppKeys.bulkComplete));
    await pumpAndSettle();
  }

  Future<void> _selectTodoListItems(List<String> todoListItems) async {
    for (final todoListItem in todoListItems) {
      final row = find.ancestor(
          of: find.text(todoListItem), matching: find.byType(Row));
      final checkbox =
          find.descendant(of: row, matching: find.byType(Checkbox));
      await tap(checkbox);
      await pumpAndSettle();
    }
  }

  Future<void> _waitUntilGone(Finder finder) async {
    bool timerDone = false;
    final timer = Timer(const Duration(seconds: 5), () => timerDone = true);
    while (timerDone != true) {
      await pump();

      final gone = !any(finder);
      if (gone) {
        timerDone = true;
      }
    }
    timer.cancel();
  }
}
