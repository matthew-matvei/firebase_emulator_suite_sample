import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'todo_list_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "any",
          appId: "firebase_emulator_suite_sample",
          messagingSenderId: "any",
          projectId: "demo-firebase-emulator-suite"));

  await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);

  runApp(const _TodoListApp());
}

class _TodoListApp extends StatefulWidget {
  const _TodoListApp();

  @override
  State<_TodoListApp> createState() => _TodoListAppState();
}

class _TodoListAppState extends State<_TodoListApp> {
  var _creatingNewTodo = false;
  var _todoListItems = <TodoListItem>[];
  TodoListItem? _todoListItemBeingEdited;
  final _selectedTodoListItems = <TodoListItem>{};

  @override
  Widget build(BuildContext context) {
    var nonCompletedTodoListItems =
        _todoListItems.where((item) => !item.completed).toList();
    var completedTodoListItems =
        _todoListItems.where((item) => item.completed).toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Todos"),
        ),
        body: Center(
          child: Column(
            children: [
              ButtonBar(
                children: [_bulkCompleteButton(), _bulkDeleteButton()],
              ),
              Expanded(
                child: ListView(
                  key: AppKeys.todoList,
                  children: [
                    if (_creatingNewTodo) _newTodoText(),
                    if (!_creatingNewTodo) _createNewTodoButton(),
                    ...nonCompletedTodoListItems
                        .asMap()
                        .entries
                        .map(_toTodoListItemRow)
                        .toList(),
                    if (completedTodoListItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: Text("Completed"),
                      ),
                      ...completedTodoListItems
                          .asMap()
                          .entries
                          .map(_toTodoListItemRow)
                          .toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toTodoListItemRow(MapEntry<int, TodoListItem> entry) => Row(
        children: [
          _todoListItemCheckbox(entry.value),
          Expanded(
            child: _todoListItem(entry),
          ),
        ],
      );

  TextField _todoListItem(MapEntry<int, TodoListItem> todoListItemEntry) {
    return TextField(
      readOnly: _todoListItemBeingEdited != todoListItemEntry.value,
      style: TextStyle(
          decoration: todoListItemEntry.value.completed
              ? TextDecoration.lineThrough
              : null),
      onTap: () {
        setState(() {
          _todoListItemBeingEdited = todoListItemEntry.value;
        });
      },
      onSubmitted: (newTodoListItemName) {
        setState(() {
          _todoListItems[todoListItemEntry.key].name = newTodoListItemName;
          _todoListItemBeingEdited = null;
        });
      },
      controller: TextEditingController(text: todoListItemEntry.value.name),
    );
  }

  Checkbox _todoListItemCheckbox(TodoListItem todoListItem) {
    return Checkbox(
        value: _selectedTodoListItems.contains(todoListItem),
        onChanged: (selected) {
          setState(() {
            if (selected ?? false) {
              _selectedTodoListItems.add(todoListItem);
            } else {
              _selectedTodoListItems.remove(todoListItem);
            }
          });
        });
  }

  ElevatedButton _createNewTodoButton() {
    return ElevatedButton.icon(
        key: AppKeys.createNewTodo,
        onPressed: () {
          setState(() {
            _creatingNewTodo = true;
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Create new todo item"));
  }

  TextField _newTodoText() {
    return TextField(
      key: AppKeys.newTodoText,
      autofocus: true,
      onSubmitted: (newTodoListItemName) {
        setState(() {
          _todoListItems.add(TodoListItem(name: newTodoListItemName));
          _creatingNewTodo = false;
        });
      },
    );
  }

  IconButton _bulkDeleteButton() {
    return IconButton(
        key: AppKeys.bulkDelete,
        onPressed: () {
          setState(() {
            _todoListItems = _todoListItems
                .where((element) => !_selectedTodoListItems.contains(element))
                .toList();
            _selectedTodoListItems.clear();
          });
        },
        icon: const Icon(Icons.delete));
  }

  IconButton _bulkCompleteButton() {
    return IconButton(
        key: AppKeys.bulkComplete,
        onPressed: () {
          setState(() {
            for (final todoListItem in _todoListItems) {
              if (_selectedTodoListItems.contains(todoListItem)) {
                todoListItem.completed = true;
              }
            }
            _selectedTodoListItems.clear();
          });
        },
        icon: const Icon(Icons.done));
  }
}

class AppKeys {
  static Key todoList = LabeledGlobalKey("TodoList");
  static Key createNewTodo = LabeledGlobalKey("CreateNewTodo");
  static Key newTodoText = LabeledGlobalKey("NewTodoText");
  static Key bulkDelete = LabeledGlobalKey("BulkDelete");
  static Key bulkComplete = LabeledGlobalKey("BulkComplete");
}
