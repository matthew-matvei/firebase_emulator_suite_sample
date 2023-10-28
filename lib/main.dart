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
  var _creatingNewTodo = false;
  final _todoListItems = <String>[];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Todos"),
        ),
        body: Center(
          child: ListView(
            key: const ValueKey<String>("TodoList"),
            children: [
              if (_creatingNewTodo)
                TextField(
                  key: AppKeys.newTodoText,
                  autofocus: true,
                  onSubmitted: (newTodoText) {
                    setState(() {
                      _todoListItems.add(newTodoText);
                      _creatingNewTodo = false;
                    });
                  },
                ),
              if (!_creatingNewTodo)
                ElevatedButton.icon(
                    key: AppKeys.createNewTodo,
                    onPressed: () {
                      setState(() {
                        _creatingNewTodo = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Create new todo item")),
              ..._todoListItems.map((todoListItem) => Text(todoListItem))
            ],
          ),
        ),
      ),
    );
  }
}

class AppKeys {
  static Key todoList = const ValueKey<String>("TodoList");
  static Key createNewTodo = const ValueKey<String>("CreateNewTodo");
  static Key newTodoText = const ValueKey<String>("NewTodoText");
}
