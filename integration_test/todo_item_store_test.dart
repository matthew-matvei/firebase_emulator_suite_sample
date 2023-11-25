import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_emulator_suite_sample/todo_item_store.dart';
import 'package:firebase_emulator_suite_sample/todo_list_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_emulator_suite_sample/main.dart' as app
    show initialise;

import 'test_setup.dart';
import 'test_user.dart';

void main() async {
  setUpAll(() async {
    await app.initialise();
  });

  setUp(() async {
    await seedTestUsers();
  });

  tearDown(() async {
    await deleteTestData();
  });

  testWidgets(
      "Deleting a todo while someone else completes it throws a TodoItemModifiedException",
      (tester) async {
    final store = FirestoreTodoItemStore();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: TestUsers.bob.userName, password: TestUsers.bob.password);

    final todosToBeDeleted =
        List.generate(100, (_) => TodoListItem(name: "To be deleted"));
    for (final todo in todosToBeDeleted) {
      await store.create(todo);
    }

    for (final todo in todosToBeDeleted) {
      todo.completed = true;
    }

    final todoCompletion = store.saveAll(todosToBeDeleted);
    final todoDeletion =
        store.deleteAll(todosToBeDeleted.map((item) => item.id));

    final concurrentActions = Future.wait([todoCompletion, todoDeletion]);

    try {
      await concurrentActions;
      fail("Expected concurrent actions to fail");
    } on TodoItemModifiedException {
      // We received the expected exception
    } catch (error) {
      fail("Expected TodoItemModifiedException, but got error '$error'");
    }

    expect(
      await store.getAll(),
      contains(predicate<TodoListItem>((item) =>
          item.id ==
          todosToBeDeleted.firstWhere((element) => element.id == item.id).id)),
    );
  });

  testWidgets("Cannot delete items when offline", (tester) async {
    final store = FirestoreTodoItemStore();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: TestUsers.bob.userName, password: TestUsers.bob.password);

    final todoThatCantBeDeleted =
        TodoListItem(name: "This todo won't be able to be deleted");

    await store.create(todoThatCantBeDeleted);

    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);
    await FirebaseFirestore.instance.disableNetwork();

    Future<void> deletingTodosWhileOffline() =>
        store.deleteAll([todoThatCantBeDeleted.id]);

    await expectLater(
      deletingTodosWhileOffline,
      throwsA(isA<TransactionWhileOfflineException>()),
    );
  }, skip: true);
}
