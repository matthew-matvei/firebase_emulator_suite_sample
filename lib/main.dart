import 'package:flutter/material.dart';

void main() {
  runApp(const _TodoListApp());
}

class _TodoListApp extends StatelessWidget {
  const _TodoListApp();

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
          ),
        ),
      ),
    );
  }
}
