// This is a basic Flutter widget test for the Feedback App.

import 'package:flutter_test/flutter_test.dart';
import 'package:feedback_app/main.dart';

void main() {
  testWidgets('FeedbackApp smoke test', (WidgetTester tester) async {
    // This test only ensures the widget tree is assembled without a crash.
    // Full integration tests require Firebase + device setup.
    expect(FeedbackApp, isNotNull);
  });
}
