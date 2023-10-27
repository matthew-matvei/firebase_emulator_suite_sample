import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_emulator_suite_sample/main.dart' as app;

void main() {
  testWidgets("Testing", (tester) async {
    app.main();

    await tester.pumpAndSettle();
  });
}
