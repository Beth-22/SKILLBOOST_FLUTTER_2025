import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skill_boost/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can login and land on dashboard', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Fill email & password
    await tester.enterText(find.byType(TextField).at(0), 'test@test.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');

    // Tap login
    final loginButton = find.text('LOGIN');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    // Check if redirected to student/admin dashboard
    expect(find.textContaining('Home'), findsWidgets); // Adjust based on your UI
  });
}
