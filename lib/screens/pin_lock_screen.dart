import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/military_theme.dart';
import '../l10n/app_localizations.dart';
import 'splash_screen.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinLockScreen({super.key, required this.onSuccess});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  String _savedPin = '';
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('app_pin') ?? '';
    });
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += digit;
      _isWrong = false;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isWrong = false;
      });
    }
  }

  void _verifyPin() {
    if (_enteredPin == _savedPin) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const SplashScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    } else {
      setState(() {
        _isWrong = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: MilitaryTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Lock icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MilitaryTheme.accentGreen.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: _isWrong ? MilitaryTheme.commandRed : MilitaryTheme.accentGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.get('enterPIN'),
              style: const TextStyle(
                color: MilitaryTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isWrong)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.get('wrongPIN'),
                  style: const TextStyle(
                    color: MilitaryTheme.commandRed,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isWrong
                        ? MilitaryTheme.commandRed
                        : isFilled
                            ? MilitaryTheme.accentGreen
                            : Colors.transparent,
                    border: Border.all(
                      color: _isWrong
                          ? MilitaryTheme.commandRed
                          : MilitaryTheme.accentGreen.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
            // Number pad
            _buildNumberPad(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((d) => _buildDigitButton(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((d) => _buildDigitButton(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((d) => _buildDigitButton(d)).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64),
              _buildDigitButton('0'),
              _buildActionButton(Icons.backspace_outlined, _onDeletePressed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitButton(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDigitPressed(digit),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: MilitaryTheme.surfaceDark,
          ),
          child: Text(
            digit,
            style: const TextStyle(
              color: MilitaryTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Icon(icon, color: MilitaryTheme.textSecondary, size: 24),
        ),
      ),
    );
  }
}
