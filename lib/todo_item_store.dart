import 'package:firebase_emulator_suite_sample/todo_list_item.dart';

abstract class TodoItemStore {
  Future<void> create(TodoListItem todoListItem);

  Future<List<TodoListItem>> getAll({required String organisation});
}

class InMemoryTodoItemStore implements TodoItemStore {
  final List<TodoListItem> _inMemoryStore = [];

  InMemoryTodoItemStore();

  @override
  Future<void> create(TodoListItem todoListItem) async =>
      _inMemoryStore.add(todoListItem);

  @override
  Future<List<TodoListItem>> getAll({required String organisation}) async =>
      _inMemoryStore
          .where((item) => item.organisation == organisation)
          .toList();
}
