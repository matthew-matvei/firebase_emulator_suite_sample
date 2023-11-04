import 'package:firebase_auth/firebase_auth.dart';
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

class InMemoryTodoItemStore implements TodoItemStore {
  final Map<String, List<_StoredTodoListItem>> _inMemoryStore = {};
  final CurrentSession _session;

  InMemoryTodoItemStore({required CurrentSession session}) : _session = session;

  @override
  Future<void> create(TodoListItem todoListItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError(
          "Cannot create todo list items without a currently signed-in user");
    }

    if (_inMemoryStore.containsKey(user!.metadata)) {
      _inMemoryStore[_session.user!.organisation]!.add(_StoredTodoListItem(
          item: todoListItem, createdBy: _session.user!.userName));
    } else {
      _inMemoryStore[_session.user!.organisation] = [
        _StoredTodoListItem(
            item: todoListItem, createdBy: _session.user!.userName)
      ];
    }
  }

  @override
  Future<List<TodoListItem>> getAll() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError(
          "Cannot get all todo list items without a currently signed-in user");
    }

    if (_inMemoryStore.containsKey(_session.user!.organisation)) {
      return _inMemoryStore[_session.user!.organisation]!
          .map((e) => e.item)
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> deleteAll(Iterable<String> todoItemIds) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError(
          "Cannot delete todo list items without a currently signed-in user");
    }

    if (!_inMemoryStore.containsKey(_session.user!.organisation)) {
      return;
    }

    if (_inMemoryStore[_session.user!.organisation]!.any((storedItem) =>
        todoItemIds.any((id) => id == storedItem.item.id) &&
        storedItem.createdBy != _session.user!.userName)) {
      throw ArgumentError.value(
        todoItemIds,
        "todoItemIds",
        "Cannot delete todo items created by others",
      );
    }

    _inMemoryStore[_session.user!.organisation] =
        _inMemoryStore[_session.user!.organisation]!
            .where((storedItem) =>
                !todoItemIds.any((id) => storedItem.item.id == id))
            .toList();
  }
}

class _StoredTodoListItem {
  final TodoListItem item;
  final String createdBy;
  _StoredTodoListItem({required this.item, required this.createdBy});
}
