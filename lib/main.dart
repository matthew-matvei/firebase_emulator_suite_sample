import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_emulator_suite_sample/login.dart';
import 'package:firebase_emulator_suite_sample/todo_item_store.dart';
import 'package:firebase_emulator_suite_sample/todo_list.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialise();

  runApp(TodoListApp(store: FirestoreTodoItemStore()));
}

Future<void> initialise() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "any",
          appId: "firebase_emulator_suite_sample",
          messagingSenderId: "any",
          projectId: "demo-firebase-emulator-suite"));

  await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);

  FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
}

class TodoListApp extends StatefulWidget {
  final TodoItemStore _store;

  const TodoListApp({super.key, required TodoItemStore store}) : _store = store;

  @override
  State<TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Login(),
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
