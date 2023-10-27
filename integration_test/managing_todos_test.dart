import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_emulator_suite_sample/main.dart' as app;

void main() {
  testWidgets("The user sees a list of todo items", (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text("Todos"), findsOneWidget);
  });
}
