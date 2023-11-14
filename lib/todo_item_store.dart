import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_emulator_suite_sample/main.dart';
import 'package:firebase_emulator_suite_sample/todo_list_item.dart';

abstract class TodoItemStore {
  Future<void> create(TodoListItem todoListItem);

  Future<List<TodoListItem>> getAll();

  Future<void> saveAll(Iterable<TodoListItem> todos);

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
            fromFirestore: (snapshot, _) =>
                _FirestoreTodoListItem.fromJson(snapshot.data()!),
            toFirestore: (item, _) => item.toJson())
        .set(_FirestoreTodoListItem(
            name: todoListItem.name,
            completed: todoListItem.completed,
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
            fromFirestore: (snapshot, _) =>
                _FirestoreTodoListItem.fromJson(snapshot.data()!),
            toFirestore: (item, _) => item.toJson())
        .get()
        .then((value) => value.docs.map((e) {
              final todo = e.data();
              return TodoListItem.fromExisting(
                  id: e.id, name: todo.name, completed: todo.completed);
            }).toList());
  }

  @override
  Future<void> saveAll(Iterable<TodoListItem> todos) async {
    if (_session.user == null) {
      throw StateError(
          "Cannot save todo list items without a currently signed-in user");
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final todo in todos) {
      final item = FirebaseFirestore.instance.collection("todos").doc(todo.id);

      batch.set(item, {"completed": todo.completed}, SetOptions(merge: true));
    }

    await batch.commit();
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

    try {
      await batch.commit();
    } on FirebaseException catch (ex) {
      if (ex.code == "permission-denied") {
        throw ArgumentError.value(
          todoItemIds,
          "todoItemIds",
          "Cannot delete todo items created by others",
        );
      }

      rethrow;
    }
  }
}

class _FirestoreTodoListItem {
  final String name;
  final bool completed;
  final String createdBy;
  final String organisation;

  const _FirestoreTodoListItem(
      {required this.name,
      required this.completed,
      required this.createdBy,
      required this.organisation});

  _FirestoreTodoListItem.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        completed = json["completed"] as bool,
        createdBy = json["createdBy"] as String,
        organisation = json["organisation"] as String;

  Map<String, dynamic> toJson() => {
        "name": name,
        "completed": completed,
        "createdBy": createdBy,
        "organisation": organisation
      };
}
