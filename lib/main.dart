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
                children: [_bulkDeleteButton()],
              ),
              Expanded(
                child: ListView(
                  key: const ValueKey<String>("TodoList"),
                  children: [
                    if (_creatingNewTodo) _newTodoText(),
                    if (!_creatingNewTodo) _createNewTodoButton(),
                    ..._listOfTodoItems()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _listOfTodoItems() {
    return _todoListItems.asMap().entries.map((entry) => Row(
          children: [
            _todoListItemCheckbox(entry.value),
            Expanded(
              child: _todoListItem(entry),
            ),
          ],
        ));
  }

  TextField _todoListItem(MapEntry<int, String> todoListItemEntry) {
    return TextField(
      readOnly: _todoListItemBeingEdited != todoListItemEntry.value,
      onTap: () {
        setState(() {
          _todoListItemBeingEdited = todoListItemEntry.value;
        });
      },
      onSubmitted: (newTodoListItem) {
        setState(() {
          _todoListItems[todoListItemEntry.key] = newTodoListItem;
          _todoListItemBeingEdited = null;
        });
      },
      controller: TextEditingController(text: todoListItemEntry.value),
    );
  }

  Checkbox _todoListItemCheckbox(String todoListItem) {
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
      onSubmitted: (newTodoText) {
        setState(() {
          _todoListItems.add(newTodoText);
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
}

class AppKeys {
  // TODO: make these LabeledGlobalKeys
  static Key todoList = const ValueKey<String>("TodoList");
  static Key createNewTodo = const ValueKey<String>("CreateNewTodo");
  static Key newTodoText = const ValueKey<String>("NewTodoText");
  static Key bulkDelete = const ValueKey<String>("BulkDelete");
}
