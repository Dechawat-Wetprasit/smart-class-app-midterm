import 'package:flutter_test/flutter_test.dart';
import 'package:smart_class_app/main.dart';

void main() {
  testWidgets('App starts correctly with login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartClassApp(isLoggedIn: false));
    expect(find.text('Smart Class'), findsOneWidget);
  });

  testWidgets('App starts correctly with home screen when logged in', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartClassApp(isLoggedIn: true));
    expect(find.textContaining('Smart Class'), findsAny);
  });
}
