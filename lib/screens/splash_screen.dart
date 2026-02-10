import 'package:flutter/material.dart';
import '../theme/military_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _scaleUp = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
    );

    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.darkBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scaleUp.value,
                child: Transform.translate(
                  offset: Offset(0, _slideUp.value),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Soldier helmet logo
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              MilitaryTheme.accentGreen.withOpacity(0.15),
                              MilitaryTheme.darkGreen.withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MilitaryTheme.surfaceDark,
                              border: Border.all(
                                color: MilitaryTheme.goldAccent.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: MilitaryTheme.goldAccent.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  color: MilitaryTheme.goldAccent,
                                  size: 44,
                                ),
                                const SizedBox(height: 2),
                                Icon(
                                  Icons.checklist_rounded,
                                  color: MilitaryTheme.accentGreen,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // App name
                      Text(
                        'YES SIR',
                        style: TextStyle(
                          color: MilitaryTheme.goldAccent,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: MilitaryTheme.goldAccent.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        'Your order. Executed.',
                        style: TextStyle(
                          color: MilitaryTheme.textSecondary.withOpacity(0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Loading
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: MilitaryTheme.accentGreen.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
