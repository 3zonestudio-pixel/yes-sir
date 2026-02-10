import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
        backgroundColor: MilitaryTheme.accentGreen,
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    final provider = context.watch<MissionProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).get('searchTasks'),
              prefixIcon: const Icon(Icons.search_rounded, color: MilitaryTheme.textMuted, size: 20),
              filled: true,
              fillColor: MilitaryTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return _buildFilterChip(
                    l.get('all'),
                    Icons.apps_rounded,
                    provider.statusFilter == null && !provider.showStarredOnly,
                    () => provider.clearFilters(),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return _buildFilterChip(
                    l.get('starred'),
                    Icons.star_rounded,
                    provider.showStarredOnly,
                    () => provider.setStarredOnly(!provider.showStarredOnly),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return _buildFilterChip(
                    l.get('pending'),
                    Icons.schedule_rounded,
                    provider.statusFilter == MissionStatus.pending,
                    () => provider.setStatusFilter(
                      provider.statusFilter == MissionStatus.pending ? null : MissionStatus.pending,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return _buildFilterChip(
                    l.get('active'),
                    Icons.play_circle_rounded,
                    provider.statusFilter == MissionStatus.inProgress,
                    () => provider.setStatusFilter(
                      provider.statusFilter == MissionStatus.inProgress ? null : MissionStatus.inProgress,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return _buildFilterChip(
                    l.get('done'),
                    Icons.check_circle_rounded,
                    provider.statusFilter == MissionStatus.completed,
                    () => provider.setStatusFilter(
                      provider.statusFilter == MissionStatus.completed ? null : MissionStatus.completed,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? MilitaryTheme.accentGreen.withOpacity(0.15)
              : MilitaryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? MilitaryTheme.accentGreen
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? MilitaryTheme.accentGreen : MilitaryTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? MilitaryTheme.accentGreen : MilitaryTheme.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    final provider = context.watch<MissionProvider>();
    final missions = provider.missions;

    if (missions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: MilitaryTheme.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_outlined, color: MilitaryTheme.textMuted, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).get('noTasks'),
                style: const TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).get('createFirst'),
                style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      color: MilitaryTheme.accentGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          return _buildMissionCard(missions[index]);
        },
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;
    final priorityColor = MilitaryTheme.getPriorityColor(mission.priority.index);

    return Dismissible(
      key: Key(mission.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: MilitaryTheme.commandRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: MilitaryTheme.commandRed),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).get('deleteTask'), style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 18)),
            content: Text('${AppLocalizations.of(context).get('deleteTaskConfirm')}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context).get('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context).get('delete'), style: const TextStyle(color: MilitaryTheme.commandRed)),
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
          margin: const EdgeInsets.symmetric(vertical: 5),
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
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority stripe
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Status toggle
                        GestureDetector(
                          onTap: () => _toggleMissionStatus(mission),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                                ? const Icon(Icons.check_rounded, color: MilitaryTheme.accentGreen, size: 16)
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
                                  PriorityBadge(priorityIndex: mission.priority.index, compact: true),
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  StatusBadge(statusIndex: mission.status.index),
                                  const Spacer(),
                                  if (mission.dueDate != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.schedule_rounded, size: 13, color: MilitaryTheme.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(mission.dueDate!),
                                          style: TextStyle(
                                            color: _isDueSoon(mission.dueDate!)
                                                ? MilitaryTheme.warningOrange
                                                : MilitaryTheme.textMuted,
                                            fontSize: 12,
                                            fontWeight: _isDueSoon(mission.dueDate!) ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Star
                        GestureDetector(
                          onTap: () => _toggleStar(mission),
                          child: Icon(
                            mission.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                            color: mission.isStarred
                                ? MilitaryTheme.goldAccent
                                : MilitaryTheme.textMuted,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    return diff.inHours < 24 && diff.inHours >= 0;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'yesterday';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MilitaryTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.add_task_rounded, color: MilitaryTheme.accentGreen, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context).get('newTaskTitle'),
                        style: const TextStyle(
                          color: MilitaryTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: MilitaryTheme.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).get('taskObjective'),
                      labelText: AppLocalizations.of(context).get('taskTitle'),
                      labelStyle: TextStyle(color: MilitaryTheme.accentGreen, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).get('taskDetailsHint'),
                      labelText: AppLocalizations.of(context).get('taskDetails'),
                      labelStyle: TextStyle(color: MilitaryTheme.accentGreen, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppLocalizations.of(context).get('priorityLevel'),
                    style: const TextStyle(
                      color: MilitaryTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: MissionPriority.values.map((priority) {
                      final selected = selectedPriority == priority;
                      final color = MilitaryTheme.getPriorityColor(priority.index);
                      final l = AppLocalizations.of(context);
                      final labels = [l.get('low'), l.get('med'), l.get('high'), l.get('critical')];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedPriority = priority),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.15)
                                  : MilitaryTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                labels[priority.index],
                                style: TextStyle(
                                  color: selected ? color : MilitaryTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: selectedDate != null ? MilitaryTheme.accentGreen : MilitaryTheme.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate != null
                                ? 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : AppLocalizations.of(context).get('setDueDate'),
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
                      icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                      label: Text(AppLocalizations.of(context).get('createTask')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MilitaryTheme.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.assignment_rounded, color: MilitaryTheme.accentGreen, size: 24),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).get('taskDetailsTitle'),
                style: const TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: MilitaryTheme.commandRed, size: 22),
                onPressed: widget.onDelete,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: MilitaryTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              style: const TextStyle(color: MilitaryTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              PriorityBadge(priorityIndex: _mission.priority.index),
              const SizedBox(width: 8),
              StatusBadge(statusIndex: _mission.status.index),
              const Spacer(),
              if (_mission.isStarred)
                const Icon(Icons.star_rounded, color: MilitaryTheme.goldAccent, size: 22),
            ],
          ),
          const SizedBox(height: 20),
          Builder(builder: (ctx) {
            final l = AppLocalizations.of(ctx);
            return Text(
              l.get('updateStatus'),
              style: const TextStyle(
                color: MilitaryTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          const SizedBox(height: 10),
          Builder(builder: (ctx) {
            final l = AppLocalizations.of(ctx);
            return Row(
              children: [
                _buildStatusButton(l.get('pending'), MissionStatus.pending, MilitaryTheme.statusPending),
                const SizedBox(width: 8),
                _buildStatusButton(l.get('active'), MissionStatus.inProgress, MilitaryTheme.statusInProgress),
                const SizedBox(width: 8),
                _buildStatusButton(l.get('done'), MissionStatus.completed, MilitaryTheme.statusCompleted),
              ],
            );
          }),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : MilitaryTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? color : MilitaryTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
