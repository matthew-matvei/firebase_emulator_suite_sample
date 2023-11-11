import 'package:uuid/uuid.dart';

class TodoListItem {
  final String id;
  String name;
  bool completed = false;

  TodoListItem({required this.name}) : id = const Uuid().v4();

  TodoListItem.fromExisting(
      {required this.id, required this.name, required this.completed});
}
