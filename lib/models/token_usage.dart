class TokenUsage {
  final String date; // yyyy-MM-dd
  int tokensUsed;
  final int tokenLimit;
  final bool isPremium;

  TokenUsage({
    required this.date,
    this.tokensUsed = 0,
    required this.tokenLimit,
    this.isPremium = false,
  });

  int get tokensRemaining => (tokenLimit - tokensUsed).clamp(0, tokenLimit);
  double get usagePercent => tokensUsed / tokenLimit;
  bool get hasTokens => tokensRemaining > 0;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'tokensUsed': tokensUsed,
      'tokenLimit': tokenLimit,
      'isPremium': isPremium ? 1 : 0,
    };
  }

  factory TokenUsage.fromMap(Map<String, dynamic> map) {
    return TokenUsage(
      date: map['date'] as String,
      tokensUsed: map['tokensUsed'] as int? ?? 0,
      tokenLimit: map['tokenLimit'] as int? ?? 5000,
      isPremium: (map['isPremium'] as int? ?? 0) == 1,
    );
  }
}

class UserProfile {
  bool isPremium;
  int totalMissionsCompleted;
  int currentStreak;
  int longestStreak;
  DateTime? premiumExpiry;

  UserProfile({
    this.isPremium = false,
    this.totalMissionsCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.premiumExpiry,
  });
}
