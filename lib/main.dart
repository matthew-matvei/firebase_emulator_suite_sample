import 'package:firebase_emulator_suite_sample/login.dart';
import 'package:firebase_emulator_suite_sample/todo_item_store.dart';
import 'package:firebase_emulator_suite_sample/todo_list.dart';
import 'package:flutter/material.dart';

import 'user.dart';

void main() {
  final currentSession = CurrentSession();
  runApp(TodoListApp(
      store: InMemoryTodoItemStore(session: currentSession),
      session: currentSession));
}

class TodoListApp extends StatefulWidget {
  final TodoItemStore _store;
  final CurrentSession _session;

  const TodoListApp(
      {super.key,
      required TodoItemStore store,
      required CurrentSession session})
      : _store = store,
        _session = session;

  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(session: widget._session),
      routes: {Routes.todos: (_) => TodoList(store: widget._store)},
    );
  }
}

class AppKeys {
  static Key todoList = LabeledGlobalKey("TodoList");
  static Key createNewTodo = LabeledGlobalKey("CreateNewTodo");
  static Key newTodoText = LabeledGlobalKey("NewTodoText");
  static Key bulkDelete = LabeledGlobalKey("BulkDelete");
  static Key bulkComplete = LabeledGlobalKey("BulkComplete");
  static Key userNameText = LabeledGlobalKey("UserName");
  static Key passwordText = LabeledGlobalKey("Password");
  static Key login = LabeledGlobalKey("Login");
}

class Routes {
  static String todos = "Todos";
}

class CurrentSession {
  User? user;

  CurrentSession();
}
