import 'package:flutter_test/flutter_test.dart';
import 'package:yes_sir/main.dart';
import 'package:yes_sir/services/token_manager.dart';
import 'package:yes_sir/l10n/app_localizations.dart';
import 'package:yes_sir/providers/theme_provider.dart';

void main() {
  testWidgets('Yes Sir app smoke test', (WidgetTester tester) async {
    final tokenManager = TokenManager();
    final localeProvider = LocaleProvider();
    final themeProvider = ThemeProvider();
    await tester.pumpWidget(YesSirApp(
      tokenManager: tokenManager,
      localeProvider: localeProvider,
      themeProvider: themeProvider,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(YesSirApp), findsOneWidget);
  });
}
