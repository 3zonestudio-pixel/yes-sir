import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

import 'commander_ai_screen.dart';
import 'missions_screen.dart';
import 'mission_map_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final missions = await DatabaseHelper.instance.getTopLevelMissions();
    if (mounted) {
      context.read<MissionProvider>().setMissions(missions);
      // Check for due-soon tasks and notify
      await NotificationService.instance.checkAndNotifyDueTasks(missions);
    }
  }

  String _getGreeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.get('goodMorning');
    if (hour < 17) return l.get('goodAfternoon');
    return l.get('goodEvening');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(
            getGreeting: _getGreeting,
            onNavigateToMissions: () => setState(() => _currentIndex = 1),
            onNavigateToAI: () => setState(() => _currentIndex = 3),
            onRefresh: _loadMissions,
          ),
          const MissionsScreen(),
          const MissionMapScreen(),
          const CommanderAIScreen(),
          const ReportsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, l.get('navHome')),
              _buildNavItem(1, Icons.task_alt_rounded, Icons.task_alt_outlined, l.get('navTasks')),
              _buildNavItem(2, Icons.calendar_month_rounded, Icons.calendar_month_outlined, l.get('navCalendar')),
              _buildNavItem(3, Icons.smart_toy_rounded, Icons.smart_toy_outlined, l.get('navAI')),
              _buildNavItem(4, Icons.bar_chart_rounded, Icons.bar_chart_outlined, l.get('navReports')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData icon, String label) {
    final selected = _currentIndex == index;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? primary : muted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : muted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== SIMPLIFIED DASHBOARD TAB =====
class _DashboardTab extends StatelessWidget {
  final String Function(AppLocalizations) getGreeting;
  final VoidCallback onNavigateToMissions;
  final VoidCallback onNavigateToAI;
  final Future<void> Function() onRefresh;

  const _DashboardTab({
    required this.getGreeting,
    required this.onNavigateToMissions,
    required this.onNavigateToAI,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<MissionProvider>();
    final theme = Theme.of(context);

    final todayMissions = provider.allMissions.where((m) {
      if (m.dueDate == null) return false;
      final now = DateTime.now();
      return m.dueDate!.year == now.year &&
          m.dueDate!.month == now.month &&
          m.dueDate!.day == now.day;
    }).toList();

    final pendingMissions = provider.allMissions
        .where((m) => m.status != MissionStatus.completed)
        .toList();
    final completedToday = todayMissions
        .where((m) => m.status == MissionStatus.completed)
        .length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Simple AppBar
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            expandedHeight: 90,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${getGreeting(l)} 💕',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.get('commander'),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.settings_rounded, color: theme.textTheme.bodyMedium?.color, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Simple progress card
                  _buildProgressCard(context, todayMissions.length, completedToday),

                  const SizedBox(height: 20),

                  // Today's tasks header
                  _buildSectionHeader(context, l.get('todayTasks'), Icons.today_rounded, onNavigateToMissions),

                  const SizedBox(height: 10),

                  if (todayMissions.isEmpty)
                    _buildEmptyState(context, l)
                  else
                    ...todayMissions.map((m) => _buildTaskTile(context, m)),

                  const SizedBox(height: 24),

                  if (pendingMissions.isNotEmpty) ...[
                    _buildSectionHeader(context, l.get('upcomingTasks'), Icons.upcoming_rounded, onNavigateToMissions),
                    const SizedBox(height: 10),
                    ...pendingMissions.take(5).map((m) => _buildTaskTile(context, m)),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int total, int completed) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(primary),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '$completed/$total',
                    style: TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Builder(builder: (context) {
              final l = AppLocalizations.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.get('todayProgress'),
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? l.get('noTasksScheduled')
                        : completed == total
                            ? l.get('allTasksDone')
                            : '${total - completed} ${l.get('tasksRemaining')}',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, VoidCallback onViewAll) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: Builder(builder: (context) {
            final l = AppLocalizations.of(context);
            return Text(
              '${l.get('viewAll')} →',
              style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: () async {
        final newStatus = isCompleted ? MissionStatus.pending : MissionStatus.completed;
        final updated = mission.copyWith(
          status: newStatus,
          completedAt: newStatus == MissionStatus.completed ? DateTime.now() : null,
        );
        await DatabaseHelper.instance.updateMission(updated);
        if (context.mounted) {
          context.read<MissionProvider>().updateMission(updated);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? primary.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: isCompleted ? primary : mutedColor, width: 2),
              ),
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: primary, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: TextStyle(
                      color: isCompleted ? mutedColor : textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (mission.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(mission.dueDate!),
                            style: TextStyle(color: mutedColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (mission.isStarred)
              Icon(Icons.star_rounded, color: theme.colorScheme.secondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.wb_sunny_rounded, color: theme.colorScheme.secondary.withOpacity(0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            l.get('noTasksToday'),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            l.get('noTasksTodaySub'),
            style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    if (date.hour == 0 && date.minute == 0) {
      return '$day/$month';
    }
    return '$day/$month $hour:$min';
  }
}
