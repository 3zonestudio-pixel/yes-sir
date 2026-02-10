import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';
import '../theme/military_theme.dart';
import '../widgets/military_widgets.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildMissionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMissionDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFilterBar() {
    final provider = context.watch<MissionProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: MilitaryTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: MilitaryTheme.surfaceLight, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search missions...',
              prefixIcon: const Icon(Icons.search, color: MilitaryTheme.textMuted, size: 20),
              filled: true,
              fillColor: MilitaryTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'ALL',
                  provider.statusFilter == null && !provider.showStarredOnly,
                  () => provider.clearFilters(),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  '⭐ STARRED',
                  provider.showStarredOnly,
                  () => provider.setStarredOnly(!provider.showStarredOnly),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  '⏳ PENDING',
                  provider.statusFilter == MissionStatus.pending,
                  () => provider.setStatusFilter(
                    provider.statusFilter == MissionStatus.pending ? null : MissionStatus.pending,
                  ),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  '🔄 ACTIVE',
                  provider.statusFilter == MissionStatus.inProgress,
                  () => provider.setStatusFilter(
                    provider.statusFilter == MissionStatus.inProgress ? null : MissionStatus.inProgress,
                  ),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  '✅ DONE',
                  provider.statusFilter == MissionStatus.completed,
                  () => provider.setStatusFilter(
                    provider.statusFilter == MissionStatus.completed ? null : MissionStatus.completed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? MilitaryTheme.militaryGreen.withOpacity(0.3)
              : MilitaryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? MilitaryTheme.accentGreen
                : MilitaryTheme.surfaceLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MilitaryTheme.accentGreen : MilitaryTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    final provider = context.watch<MissionProvider>();
    final missions = provider.missions;

    if (missions.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Missions',
        subtitle: 'Create your first mission to get started, Commander.',
        icon: Icons.assignment_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      color: MilitaryTheme.goldAccent,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          return _buildMissionCard(missions[index]);
        },
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;

    return Dismissible(
      key: Key(mission.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: MilitaryTheme.commandRed.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: MilitaryTheme.commandRed),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('DELETE MISSION', style: TextStyle(color: MilitaryTheme.goldAccent)),
            content: Text('Abort mission "${mission.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL', style: TextStyle(color: MilitaryTheme.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('DELETE', style: TextStyle(color: MilitaryTheme.commandRed)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await DatabaseHelper.instance.deleteMission(mission.id);
        if (mounted) {
          context.read<MissionProvider>().removeMission(mission.id);
        }
      },
      child: GestureDetector(
        onTap: () => _showMissionDetails(mission),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MilitaryTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? MilitaryTheme.accentGreen.withOpacity(0.2)
                  : MilitaryTheme.surfaceLight,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status toggle
              GestureDetector(
                onTap: () => _toggleMissionStatus(mission),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? MilitaryTheme.accentGreen.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? MilitaryTheme.accentGreen
                          : MilitaryTheme.textMuted,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: MilitaryTheme.accentGreen, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Mission details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mission.title,
                            style: TextStyle(
                              color: isCompleted
                                  ? MilitaryTheme.textMuted
                                  : MilitaryTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        PriorityBadge(
                          priorityIndex: mission.priority.index,
                          compact: true,
                        ),
                      ],
                    ),
                    if (mission.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          mission.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MilitaryTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusBadge(statusIndex: mission.status.index),
                        const Spacer(),
                        if (mission.dueDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 12, color: MilitaryTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(mission.dueDate!),
                                style: const TextStyle(
                                  color: MilitaryTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Star
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleStar(mission),
                child: Icon(
                  mission.isStarred ? Icons.star : Icons.star_border,
                  color: mission.isStarred
                      ? MilitaryTheme.goldAccent
                      : MilitaryTheme.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _toggleMissionStatus(Mission mission) async {
    final newStatus = mission.status == MissionStatus.completed
        ? MissionStatus.pending
        : MissionStatus.completed;

    final updated = mission.copyWith(
      status: newStatus,
      completedAt: newStatus == MissionStatus.completed ? DateTime.now() : null,
    );

    await DatabaseHelper.instance.updateMission(updated);
    if (mounted) {
      context.read<MissionProvider>().updateMission(updated);
    }
  }

  Future<void> _toggleStar(Mission mission) async {
    final updated = mission.copyWith(isStarred: !mission.isStarred);
    await DatabaseHelper.instance.updateMission(updated);
    if (mounted) {
      context.read<MissionProvider>().updateMission(updated);
    }
  }

  void _showMissionDetails(Mission mission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MilitaryTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MissionDetailSheet(
        mission: mission,
        onUpdate: (updated) async {
          await DatabaseHelper.instance.updateMission(updated);
          if (mounted) {
            context.read<MissionProvider>().updateMission(updated);
          }
        },
        onDelete: () async {
          await DatabaseHelper.instance.deleteMission(mission.id);
          if (mounted) {
            context.read<MissionProvider>().removeMission(mission.id);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showCreateMissionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    MissionPriority selectedPriority = MissionPriority.medium;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MilitaryTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.add_task, color: MilitaryTheme.goldAccent),
                      const SizedBox(width: 10),
                      const Text(
                        'NEW MISSION',
                        style: TextStyle(
                          color: MilitaryTheme.goldAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: MilitaryTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Mission objective...',
                      labelText: 'MISSION TITLE',
                      labelStyle: TextStyle(color: MilitaryTheme.goldAccent, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Mission details (optional)...',
                      labelText: 'DETAILS',
                      labelStyle: TextStyle(color: MilitaryTheme.goldAccent, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority selector
                  const Text(
                    'PRIORITY LEVEL',
                    style: TextStyle(
                      color: MilitaryTheme.goldAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: MissionPriority.values.map((priority) {
                      final selected = selectedPriority == priority;
                      final color = MilitaryTheme.getPriorityColor(priority.index);
                      final labels = ['LOW', 'MED', 'HIGH', 'CRIT'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedPriority = priority),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.2)
                                  : MilitaryTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected ? color : MilitaryTheme.surfaceLight,
                                width: selected ? 1.5 : 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                labels[priority.index],
                                style: TextStyle(
                                  color: selected ? color : MilitaryTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: MilitaryTheme.accentGreen,
                                surface: MilitaryTheme.cardBackground,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setModalState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MilitaryTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MilitaryTheme.surfaceLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: MilitaryTheme.textMuted, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate != null
                                ? 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Set due date (optional)',
                            style: TextStyle(
                              color: selectedDate != null
                                  ? MilitaryTheme.textPrimary
                                  : MilitaryTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;

                        final mission = Mission(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          priority: selectedPriority,
                          dueDate: selectedDate,
                        );

                        await DatabaseHelper.instance.insertMission(mission);
                        if (mounted) {
                          context.read<MissionProvider>().addMission(mission);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: const Text('DEPLOY MISSION'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MissionDetailSheet extends StatefulWidget {
  final Mission mission;
  final Function(Mission) onUpdate;
  final VoidCallback onDelete;

  const _MissionDetailSheet({
    required this.mission,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_MissionDetailSheet> createState() => _MissionDetailSheetState();
}

class _MissionDetailSheetState extends State<_MissionDetailSheet> {
  late Mission _mission;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.assignment, color: MilitaryTheme.goldAccent),
              const SizedBox(width: 10),
              const Text(
                'MISSION DETAILS',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: MilitaryTheme.commandRed, size: 22),
                onPressed: widget.onDelete,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: MilitaryTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _mission.title,
            style: const TextStyle(
              color: MilitaryTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (_mission.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _mission.description,
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Status & Priority
          Row(
            children: [
              PriorityBadge(priorityIndex: _mission.priority.index),
              const SizedBox(width: 8),
              StatusBadge(statusIndex: _mission.status.index),
              const Spacer(),
              if (_mission.isStarred)
                const Icon(Icons.star, color: MilitaryTheme.goldAccent, size: 20),
            ],
          ),

          const SizedBox(height: 20),

          // Status update buttons
          const Text(
            'UPDATE STATUS',
            style: TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusButton('PENDING', MissionStatus.pending, MilitaryTheme.statusPending),
              const SizedBox(width: 6),
              _buildStatusButton('ACTIVE', MissionStatus.inProgress, MilitaryTheme.statusInProgress),
              const SizedBox(width: 6),
              _buildStatusButton('DONE', MissionStatus.completed, MilitaryTheme.statusCompleted),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, MissionStatus status, Color color) {
    final selected = _mission.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mission = _mission.copyWith(
              status: status,
              completedAt: status == MissionStatus.completed ? DateTime.now() : null,
            );
          });
          widget.onUpdate(_mission);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.2) : MilitaryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : MilitaryTheme.surfaceLight,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? color : MilitaryTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
