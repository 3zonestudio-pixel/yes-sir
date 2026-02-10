import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';

import '../theme/military_theme.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, l.get('navHome')),
              _buildNavItem(1, Icons.rocket_launch_rounded, Icons.rocket_launch_outlined, l.get('navMissions')),
              _buildNavItem(2, Icons.calendar_month_rounded, Icons.calendar_month_outlined, l.get('navCalendar')),
              _buildNavItem(3, Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'AI'),
              _buildNavItem(4, Icons.bar_chart_rounded, Icons.bar_chart_outlined, l.get('navReports')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData icon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? MilitaryTheme.accentGreen.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? MilitaryTheme.goldAccent : MilitaryTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? MilitaryTheme.goldAccent : MilitaryTheme.textMuted,
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

// ===== DASHBOARD TAB (NEW HOME PAGE) =====
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
      color: MilitaryTheme.accentGreen,
      child: CustomScrollView(
        slivers: [
          // AppBar with greeting
          SliverAppBar(
            floating: true,
            backgroundColor: MilitaryTheme.darkBackground,
            automaticallyImplyLeading: false,
            expandedHeight: 100,
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
                            '${getGreeting(l)} 🫡',
                            style: TextStyle(
                              color: MilitaryTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.get('commander'),
                            style: const TextStyle(
                              color: MilitaryTheme.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: MilitaryTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.settings_rounded, color: MilitaryTheme.textSecondary, size: 22),
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

                  // Progress overview card
                  _buildProgressCard(context, todayMissions, completedToday),

                  const SizedBox(height: 20),

                  // Quick actions
                  _buildQuickActions(context, l),

                  const SizedBox(height: 24),

                  // Today's missions
                  _buildSectionHeader(l.get('todayMissions'), Icons.today_rounded, () => onNavigateToMissions()),

                  const SizedBox(height: 10),

                  if (todayMissions.isEmpty)
                    _buildEmptyToday(context, l)
                  else
                    ...todayMissions.map((m) => _buildMissionTile(context, m)).toList(),

                  const SizedBox(height: 24),

                  // Upcoming missions (next 7 days)
                  if (pendingMissions.isNotEmpty) ...[
                    _buildSectionHeader(l.get('upcomingMissions'), Icons.upcoming_rounded, () => onNavigateToMissions()),
                    const SizedBox(height: 10),
                    ...pendingMissions.take(5).map((m) => _buildMissionTile(context, m)).toList(),
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

  Widget _buildProgressCard(BuildContext context, List<Mission> todayMissions, int completedToday) {
    final total = todayMissions.length;
    final progress = total > 0 ? completedToday / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MilitaryTheme.militaryGreen.withOpacity(0.25),
            MilitaryTheme.accentGreen.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MilitaryTheme.accentGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: MilitaryTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(MilitaryTheme.accentGreen),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$completedToday',
                        style: const TextStyle(
                          color: MilitaryTheme.accentGreen,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '/$total',
                        style: const TextStyle(
                          color: MilitaryTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    color: MilitaryTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'No missions scheduled for today'
                      : completedToday == total
                          ? 'All missions completed! Great work! 🎖️'
                          : '${total - completedToday} missions remaining',
                  style: const TextStyle(
                    color: MilitaryTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_task_rounded,
            label: l.get('newMission'),
            color: MilitaryTheme.accentGreen,
            onTap: onNavigateToMissions,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            icon: Icons.smart_toy_rounded,
            label: l.get('aiAdvisor'),
            color: MilitaryTheme.goldAccent,
            onTap: onNavigateToAI,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            icon: Icons.summarize_rounded,
            label: l.get('dailyReport'),
            color: MilitaryTheme.infoBlue,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onViewAll) {
    return Row(
      children: [
        Icon(icon, color: MilitaryTheme.goldAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: MilitaryTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'View All →',
            style: TextStyle(color: MilitaryTheme.accentGreen, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionTile(BuildContext context, Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;
    final priorityColor = MilitaryTheme.getPriorityColor(mission.priority.index);

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
          color: MilitaryTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: priorityColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? MilitaryTheme.accentGreen.withOpacity(0.15) : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? MilitaryTheme.accentGreen : MilitaryTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: MilitaryTheme.accentGreen, size: 16)
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
                      color: isCompleted ? MilitaryTheme.textMuted : MilitaryTheme.textPrimary,
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
                          Icon(Icons.access_time_rounded, size: 12, color: MilitaryTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(mission.dueDate!),
                            style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (mission.isStarred)
              const Icon(Icons.star_rounded, color: MilitaryTheme.goldAccent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyToday(BuildContext context, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.wb_sunny_rounded, color: MilitaryTheme.goldAccent.withOpacity(0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            l.get('noMissionsToday'),
            style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            l.get('noMissionsTodaySub'),
            style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
