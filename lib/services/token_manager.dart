import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import '../models/token_usage.dart';

class TokenManager extends ChangeNotifier {
  TokenUsage? _todayUsage;
  bool _isPremium = false;

  TokenUsage? get todayUsage => _todayUsage;
  bool get isPremium => _isPremium;
  int get tokensRemaining => _todayUsage?.tokensRemaining ?? 0;
  int get tokensUsed => _todayUsage?.tokensUsed ?? 0;
  int get tokenLimit => _todayUsage?.tokenLimit ?? 5000;
  double get usagePercent => _todayUsage?.usagePercent ?? 0.0;
  bool get hasTokens => _todayUsage?.hasTokens ?? true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    await _loadTodayUsage();
  }

  Future<void> _loadTodayUsage() async {
    _todayUsage = await DatabaseHelper.instance.getTodayTokenUsage(_isPremium);
    notifyListeners();
  }

  Future<bool> consumeTokens(int amount) async {
    if (_todayUsage == null) await _loadTodayUsage();
    if (!hasTokens || tokensRemaining < amount) return false;

    _todayUsage!.tokensUsed += amount;
    await DatabaseHelper.instance
        .updateTokenUsage(_todayUsage!.date, _todayUsage!.tokensUsed);
    notifyListeners();
    return true;
  }

  int estimateTokens(String text) {
    // Rough estimate: ~4 chars per token (similar to GPT tokenization)
    return (text.length / 4).ceil().clamp(1, 5000);
  }

  Future<void> upgradeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = true;
    await prefs.setBool('isPremium', true);
    // Update current day's token limit to premium
    if (_todayUsage != null) {
      await DatabaseHelper.instance.updateTokenLimit(_todayUsage!.date, 10000);
    }
    await _loadTodayUsage();
  }

  Future<void> downgradeToFree() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = false;
    await prefs.setBool('isPremium', false);
    // Update current day's token limit to free
    if (_todayUsage != null) {
      await DatabaseHelper.instance.updateTokenLimit(_todayUsage!.date, 5000);
    }
    await _loadTodayUsage();
  }
}
