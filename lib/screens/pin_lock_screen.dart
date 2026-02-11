import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('app_pin');
    setState(() {
      _savedPin = pin ?? '';
      _isLoading = false;
    });
    // If no PIN is saved, go directly to home
    if (pin == null || pin.isEmpty) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _isWrong = false;
    });
    if (_enteredPin.length == 4) _verifyPin();
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
      _navigateToHome();
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final error = theme.colorScheme.error;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: _isWrong ? error : primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(l.get('enterPIN'),
                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w600)),
            if (_isWrong)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.get('wrongPIN'), style: TextStyle(color: error, fontSize: 14)),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isWrong ? error : filled ? primary : Colors.transparent,
                    border: Border.all(color: _isWrong ? error : primary.withOpacity(0.5), width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildNumberPad(surfaceColor, textColor, mutedColor),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(Color surface, Color text, Color muted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          for (final row in [['1','2','3'], ['4','5','6'], ['7','8','9']])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((d) => _digit(d, surface, text)).toList(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64),
              _digit('0', surface, text),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onDeletePressed,
                  borderRadius: BorderRadius.circular(32),
                  child: SizedBox(width: 64, height: 64, child: Icon(Icons.backspace_outlined, color: muted, size: 24)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _digit(String d, Color surface, Color text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDigitPressed(d),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64, height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: surface),
          child: Text(d, style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
