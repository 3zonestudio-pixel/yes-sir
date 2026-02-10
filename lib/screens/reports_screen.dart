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
        color: MilitaryTheme.accentGreen,
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: MilitaryTheme.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics_rounded, color: MilitaryTheme.accentGreen, size: 22),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports',
              style: TextStyle(
                color: MilitaryTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your productivity overview',
              style: TextStyle(
                color: MilitaryTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
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
                'Total',
                total.toString(),
                Icons.assignment_rounded,
                MilitaryTheme.infoBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'Completed',
                completed.toString(),
                Icons.check_circle_rounded,
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
                'Active',
                inProgress.toString(),
                Icons.play_circle_rounded,
                MilitaryTheme.warningOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'Pending',
                pending.toString(),
                Icons.schedule_rounded,
                MilitaryTheme.statusPending,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, color: MilitaryTheme.accentGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Mission Distribution',
                style: TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline_rounded,
                            color: MilitaryTheme.textMuted.withOpacity(0.3), size: 48),
                        const SizedBox(height: 8),
                        const Text(
                          'No data yet',
                          style: TextStyle(color: MilitaryTheme.textMuted),
                        ),
                      ],
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
                            sectionsSpace: 3,
                            centerSpaceRadius: 35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Completed', MilitaryTheme.accentGreen),
                          const SizedBox(height: 10),
                          _buildLegendItem('Active', MilitaryTheme.warningOrange),
                          const SizedBox(height: 10),
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
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: MilitaryTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTokenUsageCard(TokenManager tokenManager) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: MilitaryTheme.goldAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Token Usage',
                style: TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (tokenManager.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MilitaryTheme.goldDark, MilitaryTheme.goldAccent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 14),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MilitaryTheme.goldAccent.withOpacity(0.08),
            MilitaryTheme.goldAccent.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MilitaryTheme.goldAccent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MilitaryTheme.goldAccent.withOpacity(0.1),
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
                  'Day Streak 🔥',
                  style: TextStyle(
                    color: MilitaryTheme.goldAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _streak > 0
                      ? '$_streak day${_streak != 1 ? 's' : ''} of consecutive completion!'
                      : 'Complete a mission to start your streak!',
                  style: const TextStyle(
                    color: MilitaryTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_fire_department_rounded, color: MilitaryTheme.warningOrange, size: 30),
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
      message = "Outstanding! You're crushing it 💪";
      icon = Icons.emoji_events_rounded;
    } else if (rate >= 50) {
      message = "Great progress! Keep the momentum going 🚀";
      icon = Icons.trending_up_rounded;
    } else if (rate > 0) {
      message = "You've got this! Focus on what matters most ✨";
      icon = Icons.flag_rounded;
    } else {
      message = "Welcome! Create your first mission to begin 🎯";
      icon = Icons.rocket_launch_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MilitaryTheme.accentGreen.withOpacity(0.08),
            MilitaryTheme.accentGreen.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MilitaryTheme.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MilitaryTheme.accentGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
