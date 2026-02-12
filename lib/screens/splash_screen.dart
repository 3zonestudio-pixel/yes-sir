import 'package:flutter/material.dart';
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
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4, curve: Curves.easeIn)),
    );

    _scaleUp = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
    );

    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );

    _bounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.bounceOut)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1625), const Color(0xFF2D2645), const Color(0xFF1A1625)]
                : [const Color(0xFFF0FAF5), const Color(0xFFE3F5ED), const Color(0xFFE8F8F5)],
          ),
        ),
        child: Center(
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
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 160, height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    primary.withOpacity(0.15),
                                    secondary.withOpacity(0.08),
                                    Colors.transparent,
                                  ]),
                                ),
                              ),
                              Container(
                                width: 120, height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 30, spreadRadius: 5)],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    width: 120, height: 120, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 120, height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(colors: [primary, secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                        ),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.favorite_rounded, color: Colors.white, size: 44),
                                            SizedBox(height: 2),
                                            Icon(Icons.checklist_rounded, color: Colors.white70, size: 22),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(top: 10, right: 20, child: Opacity(opacity: _bounce.value, child: Text('✨', style: TextStyle(fontSize: 20 * _bounce.value)))),
                              Positioned(bottom: 15, left: 15, child: Opacity(opacity: _bounce.value, child: Text('🌿', style: TextStyle(fontSize: 16 * _bounce.value)))),
                              Positioned(top: 25, left: 10, child: Opacity(opacity: _bounce.value, child: Text('⭐', style: TextStyle(fontSize: 14 * _bounce.value)))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'YES SIR',
                          style: TextStyle(
                            color: primary,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            shadows: [Shadow(color: primary.withOpacity(0.3), blurRadius: 20)],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Opacity(
                          opacity: _bounce.value,
                          child: Text(
                            'Your tasks, done with love! 💕',
                            style: TextStyle(color: mutedColor.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: 32, height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: primary.withOpacity(0.5), strokeCap: StrokeCap.round),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
