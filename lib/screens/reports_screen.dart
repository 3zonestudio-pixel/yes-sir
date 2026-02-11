import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/database_helper.dart';
import '../services/token_manager.dart';

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
    final l = AppLocalizations.of(context);
    final tokenManager = context.watch<TokenManager>();
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: theme.colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(l),
            const SizedBox(height: 16),
            _buildOverviewCards(l),
            const SizedBox(height: 20),
            _buildMissionPieChart(l),
            const SizedBox(height: 20),
            _buildTokenUsageCard(tokenManager, l),
            const SizedBox(height: 20),
            _buildStreakCard(l),
            const SizedBox(height: 20),
            _buildMotivationalCard(l),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.analytics_rounded, color: primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.get('reports'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(l.get('productivityOverview'), style: TextStyle(color: mutedColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards(AppLocalizations l) {
    final theme = Theme.of(context);
    final total = _stats['total'] ?? 0;
    final completed = _stats['completed'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final inProgress = _stats['inProgress'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(l.get('total'), total.toString(), Icons.assignment_rounded, theme.colorScheme.tertiary)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(l.get('completed'), completed.toString(), Icons.check_circle_rounded, Colors.green)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard(l.get('active'), inProgress.toString(), Icons.play_circle_rounded, Colors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(l.get('pending'), pending.toString(), Icons.schedule_rounded, Colors.blueGrey)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMissionPieChart(AppLocalizations l) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    final completed = (_stats['completed'] ?? 0).toDouble();
    final pending = (_stats['pending'] ?? 0).toDouble();
    final inProgress = (_stats['inProgress'] ?? 0).toDouble();
    final total = completed + pending + inProgress;

    const completedColor = Colors.green;
    const activeColor = Colors.orange;
    const pendingColor = Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(l.get('taskDistribution'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline_rounded, color: mutedColor.withOpacity(0.3), size: 48),
                        const SizedBox(height: 8),
                        Text(l.get('noDataYet'), style: TextStyle(color: mutedColor)),
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
                              PieChartSectionData(value: completed, color: completedColor, title: '${(completed / total * 100).toStringAsFixed(0)}%', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), radius: 50),
                              PieChartSectionData(value: inProgress, color: activeColor, title: '${(inProgress / total * 100).toStringAsFixed(0)}%', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), radius: 50),
                              PieChartSectionData(value: pending, color: pendingColor, title: '${(pending / total * 100).toStringAsFixed(0)}%', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), radius: 50),
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
                          _buildLegendItem(l.get('completed'), completedColor),
                          const SizedBox(height: 10),
                          _buildLegendItem(l.get('active'), activeColor),
                          const SizedBox(height: 10),
                          _buildLegendItem(l.get('pending'), pendingColor),
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
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: secondaryText, fontSize: 13)),
      ],
    );
  }

  Widget _buildTokenUsageCard(TokenManager tokenManager, AppLocalizations l) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final secondary = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryText = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final fillBg = theme.colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: secondary, size: 20),
              const SizedBox(width: 8),
              Text(l.get('aiTokenUsage'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (tokenManager.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(10)),
                  child: Text(l.get('premium'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.get('today'), style: TextStyle(color: secondaryText, fontSize: 13)),
              Text('${tokenManager.tokensUsed} / ${tokenManager.tokenLimit}', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: tokenManager.usagePercent.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: fillBg,
              valueColor: AlwaysStoppedAnimation(
                tokenManager.usagePercent > 0.8
                    ? theme.colorScheme.error
                    : tokenManager.usagePercent > 0.5
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.get('thisWeekTotal'), style: TextStyle(color: mutedColor, fontSize: 12)),
              Text('$_totalTokensUsedWeek ${l.get('tokensUsed')}', style: TextStyle(color: secondaryText, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(AppLocalizations l) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    final secondaryText = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: secondary.withOpacity(0.1)),
            child: Center(
              child: Text('$_streak', style: TextStyle(color: secondary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.get('dayStreak'), style: TextStyle(color: secondary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  _streak > 0 ? '$_streak ${l.get('daysConsecutive')}' : l.get('startStreak'),
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 30),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(AppLocalizations l) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondaryText = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final completed = _stats['completed'] ?? 0;
    final total = _stats['total'] ?? 1;
    final rate = total > 0 ? (completed / total * 100) : 0;

    String message;
    IconData icon;

    if (rate >= 80) {
      message = l.get('outstanding');
      icon = Icons.emoji_events_rounded;
    } else if (rate >= 50) {
      message = l.get('greatProgress');
      icon = Icons.trending_up_rounded;
    } else if (rate > 0) {
      message = l.get('youGotThis');
      icon = Icons.flag_rounded;
    } else {
      message = l.get('welcomeCreate');
      icon = Icons.rocket_launch_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(message, style: TextStyle(color: secondaryText, fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}
