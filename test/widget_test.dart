import 'package:flutter_test/flutter_test.dart';

import 'package:smart_home_ai/main.dart';

void main() {
  testWidgets('SmartHomeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pump();
    expect(find.text('Smart Home AI'), findsWidgets);
  });
}
