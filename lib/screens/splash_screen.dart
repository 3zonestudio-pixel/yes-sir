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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _scaleUp = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            MilitaryTheme.militaryGreen.withOpacity(0.4),
                            MilitaryTheme.darkGreen.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
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
                      child: const Icon(
                        Icons.military_tech,
                        color: MilitaryTheme.goldAccent,
                        size: 60,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App name
                    const Text(
                      'YES SIR',
                      style: TextStyle(
                        color: MilitaryTheme.goldAccent,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'YOUR ORDER. EXECUTED.',
                      style: TextStyle(
                        color: MilitaryTheme.textSecondary.withOpacity(0.7),
                        fontSize: 14,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MilitaryTheme.goldAccent.withOpacity(0.5),
                      ),
                    ),
                  ],
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
