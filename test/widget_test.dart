import 'package:flutter_test/flutter_test.dart';
import 'package:yes_sir/main.dart';
import 'package:yes_sir/services/token_manager.dart';
import 'package:yes_sir/l10n/app_localizations.dart';

void main() {
  testWidgets('Yes Sir app smoke test', (WidgetTester tester) async {
    final tokenManager = TokenManager();
    final localeProvider = LocaleProvider();
    await tester.pumpWidget(YesSirApp(
      tokenManager: tokenManager,
      localeProvider: localeProvider,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(YesSirApp), findsOneWidget);
  });
}
