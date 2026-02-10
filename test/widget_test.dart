import 'package:flutter_test/flutter_test.dart';
import 'package:yes_sir/main.dart';
import 'package:yes_sir/services/token_manager.dart';

void main() {
  testWidgets('Yes Sir app smoke test', (WidgetTester tester) async {
    final tokenManager = TokenManager();
    await tester.pumpWidget(YesSirApp(tokenManager: tokenManager));
    expect(find.text('YES SIR'), findsOneWidget);
  });
}
