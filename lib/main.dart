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
  var _todoListItems = <String>[];
  String? _todoListItemBeingEdited;
  final _selectedTodoListItems = <String>{};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Todos"),
        ),
        body: Center(
          child: Column(
            children: [
              ButtonBar(
                children: [
                  IconButton(
                      key: AppKeys.bulkDelete,
                      onPressed: () {
                        setState(() {
                          _todoListItems = _todoListItems
                              .where((element) =>
                                  !_selectedTodoListItems.contains(element))
                              .toList();
                          _selectedTodoListItems.clear();
                        });
                      },
                      icon: const Icon(Icons.delete))
                ],
              ),
              Expanded(
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
                    ..._todoListItems.asMap().entries.map((entry) => Row(
                          children: [
                            Checkbox(
                                value: _selectedTodoListItems
                                    .contains(entry.value),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected ?? false) {
                                      _selectedTodoListItems.add(entry.value);
                                    } else {
                                      _selectedTodoListItems
                                          .remove(entry.value);
                                    }
                                  });
                                }),
                            Expanded(
                              child: TextField(
                                readOnly:
                                    _todoListItemBeingEdited != entry.value,
                                onTap: () {
                                  setState(() {
                                    _todoListItemBeingEdited = entry.value;
                                  });
                                },
                                onSubmitted: (newTodoListItem) {
                                  setState(() {
                                    _todoListItems[entry.key] = newTodoListItem;
                                    _todoListItemBeingEdited = null;
                                  });
                                },
                                controller:
                                    TextEditingController(text: entry.value),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppKeys {
  // TODO: make these LabeledGlobalKeys
  static Key todoList = const ValueKey<String>("TodoList");
  static Key createNewTodo = const ValueKey<String>("CreateNewTodo");
  static Key newTodoText = const ValueKey<String>("NewTodoText");
  static Key bulkDelete = const ValueKey<String>("BulkDelete");
}
