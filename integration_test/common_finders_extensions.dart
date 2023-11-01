import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension ExtendedFinders on CommonFinders {
  Finder completedTodoListItem(String todoListItem) => find.ancestor(
      of: find.text(todoListItem),
      matching: find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.style?.decoration == TextDecoration.lineThrough));
}
