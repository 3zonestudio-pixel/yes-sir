import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';
import '../services/token_manager.dart';
import '../theme/military_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, int> _stats = {};
  int _totalTokensUsedWeek = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseHelper.instance.getMissionStats();
    final tokenHistory = await DatabaseHelper.instance.getTokenUsageHistory(days: 7);

    int totalTokens = 0;
    for (var usage in tokenHistory) {
      totalTokens += usage.tokensUsed;
    }

    // Calculate streak (days with at least 1 completed mission)
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final dayMissions = await DatabaseHelper.instance.getCompletedMissionsByDateRange(
        DateTime(day.year, day.month, day.day),
        DateTime(day.year, day.month, day.day, 23, 59, 59),
      );
      if (dayMissions.isEmpty && i > 0) break;
      if (dayMissions.isNotEmpty) streak++;
    }

    if (mounted) {
      setState(() {
        _stats = stats;
        _totalTokensUsedWeek = totalTokens;
        _streak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: MilitaryTheme.goldAccent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildOverviewCards(),
            const SizedBox(height: 20),
            _buildMissionPieChart(),
            const SizedBox(height: 20),
            _buildTokenUsageCard(tokenManager),
            const SizedBox(height: 20),
            _buildStreakCard(),
            const SizedBox(height: 20),
            _buildMotivationalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.analytics, color: MilitaryTheme.goldAccent, size: 22),
        const SizedBox(width: 10),
        const Text(
          'AFTER-ACTION REPORT',
          style: TextStyle(
            color: MilitaryTheme.goldAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: MilitaryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MilitaryTheme.surfaceLight),
          ),
          child: Text(
            'TODAY',
            style: TextStyle(
              color: MilitaryTheme.accentGreen.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    final total = _stats['total'] ?? 0;
    final completed = _stats['completed'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final inProgress = _stats['inProgress'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'TOTAL',
                total.toString(),
                Icons.assignment,
                MilitaryTheme.infoBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'COMPLETED',
                completed.toString(),
                Icons.check_circle,
                MilitaryTheme.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'IN PROGRESS',
                inProgress.toString(),
                Icons.play_circle_filled,
                MilitaryTheme.warningOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'PENDING',
                pending.toString(),
                Icons.schedule,
                MilitaryTheme.statusPending,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPieChart() {
    final completed = (_stats['completed'] ?? 0).toDouble();
    final pending = (_stats['pending'] ?? 0).toDouble();
    final inProgress = (_stats['inProgress'] ?? 0).toDouble();
    final total = completed + pending + inProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MilitaryTheme.militaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: MilitaryTheme.goldAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'MISSION DISTRIBUTION',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          total == 0
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No mission data yet',
                      style: TextStyle(color: MilitaryTheme.textMuted),
                    ),
                  ),
                )
              : SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: completed,
                                color: MilitaryTheme.accentGreen,
                                title: '${(completed / total * 100).toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: inProgress,
                                color: MilitaryTheme.warningOrange,
                                title: '${(inProgress / total * 100).toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: pending,
                                color: MilitaryTheme.statusPending,
                                title: '${(pending / total * 100).toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                radius: 50,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Completed', MilitaryTheme.accentGreen),
                          const SizedBox(height: 8),
                          _buildLegendItem('In Progress', MilitaryTheme.warningOrange),
                          const SizedBox(height: 8),
                          _buildLegendItem('Pending', MilitaryTheme.statusPending),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: MilitaryTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTokenUsageCard(TokenManager tokenManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MilitaryTheme.militaryCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: MilitaryTheme.goldAccent, size: 18),
              const SizedBox(width: 8),
              const Text(
                'AI TOKEN USAGE',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (tokenManager.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MilitaryTheme.goldDark, MilitaryTheme.goldAccent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Today's usage bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today',
                style: TextStyle(color: MilitaryTheme.textSecondary, fontSize: 13),
              ),
              Text(
                '${tokenManager.tokensUsed} / ${tokenManager.tokenLimit}',
                style: const TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tokenManager.usagePercent.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: MilitaryTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation(
                tokenManager.usagePercent > 0.8
                    ? MilitaryTheme.commandRed
                    : tokenManager.usagePercent > 0.5
                        ? MilitaryTheme.warningOrange
                        : MilitaryTheme.accentGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Week total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This week total',
                style: TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
              ),
              Text(
                '$_totalTokensUsedWeek tokens',
                style: const TextStyle(
                  color: MilitaryTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MilitaryTheme.goldenAccentCard,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  MilitaryTheme.goldDark.withOpacity(0.3),
                  MilitaryTheme.goldAccent.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                '$_streak',
                style: const TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MISSION STREAK',
                  style: TextStyle(
                    color: MilitaryTheme.goldAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _streak > 0
                      ? '$_streak day${_streak != 1 ? 's' : ''} of consecutive mission completion!'
                      : 'Complete a mission to start your streak!',
                  style: const TextStyle(
                    color: MilitaryTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_fire_department, color: MilitaryTheme.warningOrange, size: 28),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard() {
    final completed = _stats['completed'] ?? 0;
    final total = _stats['total'] ?? 1;
    final rate = total > 0 ? (completed / total * 100) : 0;

    String message;
    IconData icon;

    if (rate >= 80) {
      message = "Outstanding performance, Commander! You're a true leader.";
      icon = Icons.military_tech;
    } else if (rate >= 50) {
      message = "Good progress, Commander. Keep pushing forward.";
      icon = Icons.trending_up;
    } else if (rate > 0) {
      message = "Room for improvement, Commander. Focus on high-priority targets.";
      icon = Icons.flag;
    } else {
      message = "Welcome, Commander. Create your first mission to begin.";
      icon = Icons.rocket_launch;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MilitaryTheme.militaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MilitaryTheme.accentGreen.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: MilitaryTheme.accentGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
