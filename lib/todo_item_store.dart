import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FbAuth;
import 'package:firebase_emulator_suite_sample/todo_list_item.dart';
import 'package:firebase_emulator_suite_sample/user.dart';

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
  User? _currentUser;
  FbAuth.User? _currentFbUser;

  FirestoreTodoItemStore() {
    FbAuth.FirebaseAuth.instance.userChanges().listen((newUser) {
      _currentUser = null;
      _currentFbUser = newUser;
    });
  }

  @override
  Future<void> create(TodoListItem todoListItem) async {
    final user = await _resolveCurrentUser();
    if (user == null) {
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
            createdBy: user.userName,
            organisation: user.organisation));
  }

  @override
  Future<List<TodoListItem>> getAll() async {
    final user = await _resolveCurrentUser();
    if (user == null) {
      throw StateError(
          "Cannot get all todo list items without a currently signed-in user");
    }

    return await FirebaseFirestore.instance
        .collection("todos")
        .where("organisation", isEqualTo: user.organisation)
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
    final user = await _resolveCurrentUser();
    if (user == null) {
      throw StateError(
          "Cannot save todo list items without a currently signed-in user");
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final todo in todos) {
      batch.set(
        _todoItemReference(todo.id),
        {"completed": todo.completed},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  @override
  Future<void> deleteAll(Iterable<String> todoItemIds) async {
    final user = await _resolveCurrentUser();
    if (user == null) {
      throw StateError(
          "Cannot delete todo list items without a currently signed-in user");
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (final itemId in todoItemIds) {
          final _ = await transaction.get(_todoItemReference(itemId));
        }

        for (final itemId in todoItemIds) {
          transaction.delete(_todoItemReference(itemId));
        }
      }, maxAttempts: 1);
    } catch (error) {
      if (error.toString().contains("permission-denied")) {
        throw ArgumentError.value(
          todoItemIds,
          "todoItemIds",
          "Cannot delete todo items created by others",
        );
      }

      if (error.toString().contains("failed-precondition")) {
        throw TodoItemModifiedException();
      }

      rethrow;
    }
  }

  DocumentReference<Map<String, dynamic>> _todoItemReference(String todoId) =>
      FirebaseFirestore.instance.collection("todos").doc(todoId);

  Future<User?> _resolveCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    if (_currentFbUser == null) {
      return null;
    }

    final userInfo = await FirebaseFirestore.instance
        .collection("users")
        .doc(_currentFbUser!.email)
        .get()
        .then((value) => value.data());

    if (userInfo == null) {
      throw StateError(
          "Failed to find information for user with email ${_currentFbUser!.email}");
    }

    if (_currentUser != null) {
      return _currentUser;
    }

    _currentUser = User(
        userName: _currentFbUser!.email!,
        organisation: userInfo["organisation"] as String);

    return _currentUser;
  }
}

class TodoItemModifiedException implements Exception {}

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
