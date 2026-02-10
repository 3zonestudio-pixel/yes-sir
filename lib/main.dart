import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/military_theme.dart';
import 'services/token_manager.dart';
import 'providers/mission_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';

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

  runApp(YesSirApp(tokenManager: tokenManager, localeProvider: localeProvider));
}

class YesSirApp extends StatelessWidget {
  final TokenManager tokenManager;
  final LocaleProvider localeProvider;

  const YesSirApp({
    super.key,
    required this.tokenManager,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tokenManager),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return MaterialApp(
            title: 'Yes Sir',
            debugShowCheckedModeBanner: false,
            theme: MilitaryTheme.darkTheme,
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
