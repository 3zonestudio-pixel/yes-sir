import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/military_theme.dart';
import 'services/token_manager.dart';
import 'providers/mission_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Lock to portrait mode (mobile only)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style (mobile only)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: MilitaryTheme.cardBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  // Initialize token manager
  final tokenManager = TokenManager();
  await tokenManager.initialize();

  runApp(YesSirApp(tokenManager: tokenManager));
}

class YesSirApp extends StatelessWidget {
  final TokenManager tokenManager;

  const YesSirApp({super.key, required this.tokenManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: tokenManager),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
      ],
      child: MaterialApp(
        title: 'Yes Sir',
        debugShowCheckedModeBanner: false,
        theme: MilitaryTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
