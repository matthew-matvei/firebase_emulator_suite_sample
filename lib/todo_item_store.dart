import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:firebase_emulator_suite_sample/todo_list_item.dart';

abstract class TodoItemStore {
  Future<void> create(TodoListItem todoListItem);

  Future<List<TodoListItem>> getAll();

  /// Deletes each [TodoListItem] referenced by its ID in [todoItemIds].
  ///
  /// Throws an [ArgumentError] if one of the items referenced by [todoItemIds]
  /// isn't owned by the current user.
  Future<void> deleteAll(Iterable<String> todoItemIds);
}

class FirestoreTodoItemStore implements TodoItemStore {
  final CurrentSession _session;

  FirestoreTodoItemStore({required CurrentSession session})
      : _session = session;

  @override
  Future<void> create(TodoListItem todoListItem) async {
    if (_session.user == null) {
      throw StateError(
          "Cannot create todo list items without a currently signed-in user");
    }

    await FirebaseFirestore.instance
        .collection("todos")
        .doc(todoListItem.id)
        .withConverter(
            fromFirestore: (snapshot, _) => _FirestoreTodoListItem(
                name: snapshot["name"] as String,
                createdBy: snapshot["createdBy"] as String,
                organisation: snapshot["organisation"] as String),
            toFirestore: (item, _) => {
                  "name": item.name,
                  "createdBy": item.createdBy,
                  "organisation": item.organisation
                })
        .set(_FirestoreTodoListItem(
            name: todoListItem.name,
            createdBy: _session.user!.userName,
            organisation: _session.user!.organisation));
  }

  @override
  Future<List<TodoListItem>> getAll() async {
    if (_session.user == null) {
      throw StateError(
          "Cannot get all todo list items without a currently signed-in user");
    }

    return await FirebaseFirestore.instance
        .collection("todos")
        .where("organisation", isEqualTo: _session.user!.organisation)
        .withConverter(
            fromFirestore: (snapshot, _) => _FirestoreTodoListItem(
                name: snapshot["name"] as String,
                createdBy: snapshot["createdBy"] as String,
                organisation: snapshot["organisation"] as String),
            toFirestore: (item, _) => {
                  "name": item.name,
                  "createdBy": item.createdBy,
                  "organisation": item.organisation
                })
        .get()
        .then((value) => value.docs
            .map((e) => e.data())
            .map((e) => TodoListItem(name: e.name))
            .toList());
  }

  @override
  Future<void> deleteAll(Iterable<String> todoItemIds) async {
    if (_session.user == null) {
      throw StateError(
          "Cannot delete todo list items without a currently signed-in user");
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final itemId in todoItemIds) {
      final item = FirebaseFirestore.instance.collection("todos").doc(itemId);
      batch.delete(item);
    }

    await batch.commit();
  }
}

class _FirestoreTodoListItem {
  final String name;
  final String createdBy;
  final String organisation;

  _FirestoreTodoListItem(
      {required this.name,
      required this.createdBy,
      required this.organisation});
}
