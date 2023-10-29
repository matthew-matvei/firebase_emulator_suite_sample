import 'package:firebase_emulator_suite_sample/login.dart';
import 'package:firebase_emulator_suite_sample/todo_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _TodoListApp());
}

class _TodoListApp extends StatefulWidget {
  const _TodoListApp();

  @override
  State<_TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<_TodoListApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Login(),
      routes: {Routes.todos: (_) => const TodoList()},
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
