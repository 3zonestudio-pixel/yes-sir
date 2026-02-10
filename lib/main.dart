import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/military_theme.dart';
import 'services/token_manager.dart';
import 'providers/mission_provider.dart';
import 'providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: MilitaryTheme.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  final tokenManager = TokenManager();
  await tokenManager.initialize();

  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Check if PIN lock is enabled
  final prefs = await SharedPreferences.getInstance();
  final hasPin = prefs.getString('app_pin') != null;

  runApp(YesSirApp(
    tokenManager: tokenManager,
    localeProvider: localeProvider,
    themeProvider: themeProvider,
    requirePin: hasPin,
  ));
}

class YesSirApp extends StatelessWidget {
  final TokenManager tokenManager;
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final bool requirePin;

  const YesSirApp({
    super.key,
    required this.tokenManager,
    required this.localeProvider,
    required this.themeProvider,
    this.requirePin = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tokenManager),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, locale, theme, _) {
          return MaterialApp(
            title: 'Yes Sir',
            debugShowCheckedModeBanner: false,
            theme: MilitaryTheme.lightTheme,
            darkTheme: MilitaryTheme.darkTheme,
            themeMode: theme.themeMode,
            locale: locale.locale,
            supportedLocales: AppLocalizations.supportedLocales
                .map((l) => Locale(l.code))
                .toList(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: requirePin
                ? PinLockScreen(onSuccess: () {})
                : const SplashScreen(),
          );
        },
      ),
    );
  }
}
