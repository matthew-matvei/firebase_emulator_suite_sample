import 'package:uuid/uuid.dart';

class TodoListItem {
  final id = const Uuid().v4();
  String name;
  bool completed = false;

  TodoListItem({required this.name});
}
