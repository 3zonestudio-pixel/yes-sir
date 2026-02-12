import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../theme/cute_theme.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildMissionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMissionDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    final provider = context.watch<MissionProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).get('searchTasks'),
              prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodySmall?.color, size: 20),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Builder(builder: (ctx) {
              final l = AppLocalizations.of(ctx);
              return Row(
                children: [
                  _buildFilterChip(l.get('all'), Icons.apps_rounded, provider.statusFilter == null && !provider.showStarredOnly, () => provider.clearFilters()),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.get('starred'), Icons.star_rounded, provider.showStarredOnly, () => provider.setStarredOnly(!provider.showStarredOnly)),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.get('pending'), Icons.schedule_rounded, provider.statusFilter == MissionStatus.pending, () => provider.setStatusFilter(provider.statusFilter == MissionStatus.pending ? null : MissionStatus.pending)),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.get('active'), Icons.play_circle_rounded, provider.statusFilter == MissionStatus.inProgress, () => provider.setStatusFilter(provider.statusFilter == MissionStatus.inProgress ? null : MissionStatus.inProgress)),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.get('done'), Icons.check_circle_rounded, provider.statusFilter == MissionStatus.completed, () => provider.setStatusFilter(provider.statusFilter == MissionStatus.completed ? null : MissionStatus.completed)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.12) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? primary : muted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? primary : muted, fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    final provider = context.watch<MissionProvider>();
    final missions = provider.missions;
    final theme = Theme.of(context);

    if (missions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(Icons.assignment_outlined, color: theme.textTheme.bodySmall?.color, size: 40),
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context).get('noTasks'), style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).get('createFirst'), style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissions,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: missions.length,
        itemBuilder: (context, index) => _buildMissionCard(missions[index]),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;
    final priorityColor = CuteTheme.getPriorityColor(mission.priority.index);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final primary = theme.colorScheme.primary;

    return Dismissible(
      key: Key(mission.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(color: theme.colorScheme.error.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(ctx).get('deleteTask')),
            content: Text(AppLocalizations.of(ctx).get('deleteTaskConfirm')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).get('cancel'))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(ctx).get('delete'), style: TextStyle(color: theme.colorScheme.error))),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await DatabaseHelper.instance.deleteMission(mission.id);
        if (mounted) context.read<MissionProvider>().removeMission(mission.id);
      },
      child: GestureDetector(
        onTap: () => _showMissionDetails(mission),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(color: priorityColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleMissionStatus(mission),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? primary.withOpacity(0.15) : Colors.transparent,
                              border: Border.all(color: isCompleted ? primary : mutedColor, width: 2),
                            ),
                            child: isCompleted ? Icon(Icons.check_rounded, color: primary, size: 16) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.title,
                                style: TextStyle(color: isCompleted ? mutedColor : textColor, fontSize: 15, fontWeight: FontWeight.w600, decoration: isCompleted ? TextDecoration.lineThrough : null),
                              ),
                              if (mission.description.isNotEmpty)
                                Padding(padding: const EdgeInsets.only(top: 4), child: Text(mission.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: mutedColor, fontSize: 13))),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildStatusLabel(mission.status, theme),
                                  const Spacer(),
                                  if (mission.dueDate != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.schedule_rounded, size: 13, color: _isDueSoon(mission.dueDate!) ? Colors.orange : mutedColor),
                                        const SizedBox(width: 4),
                                        Text(_formatDate(mission.dueDate!), style: TextStyle(color: _isDueSoon(mission.dueDate!) ? Colors.orange : mutedColor, fontSize: 12, fontWeight: _isDueSoon(mission.dueDate!) ? FontWeight.w600 : FontWeight.normal)),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _toggleStar(mission),
                          child: Icon(mission.isStarred ? Icons.star_rounded : Icons.star_border_rounded, color: mission.isStarred ? theme.colorScheme.secondary : mutedColor, size: 24),
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

  Widget _buildStatusLabel(MissionStatus status, ThemeData theme) {
    Color color;
    String text;
    switch (status) {
      case MissionStatus.pending:
        color = Colors.orange;
        text = AppLocalizations.of(context).get('pending');
        break;
      case MissionStatus.inProgress:
        color = theme.colorScheme.primary;
        text = AppLocalizations.of(context).get('active');
        break;
      case MissionStatus.completed:
        color = Colors.green;
        text = AppLocalizations.of(context).get('done');
        break;
      case MissionStatus.failed:
        color = theme.colorScheme.error;
        text = AppLocalizations.of(context).get('failed');
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  bool _isDueSoon(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now());
    return diff.inHours < 24 && diff.inHours >= 0;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final hasTime = date.hour != 0 || date.minute != 0;
    final timeStr = hasTime ? ' ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}' : '';

    if (dateOnly == today) return 'today$timeStr';
    if (dateOnly == today.add(const Duration(days: 1))) return 'tomorrow$timeStr';
    return '${date.day}/${date.month}/${date.year}$timeStr';
  }

  Future<void> _toggleMissionStatus(Mission mission) async {
    final newStatus = mission.status == MissionStatus.completed ? MissionStatus.pending : MissionStatus.completed;
    final updated = mission.copyWith(status: newStatus, completedAt: newStatus == MissionStatus.completed ? DateTime.now() : null);
    await DatabaseHelper.instance.updateMission(updated);
    if (mounted) context.read<MissionProvider>().updateMission(updated);
  }

  Future<void> _toggleStar(Mission mission) async {
    final updated = mission.copyWith(isStarred: !mission.isStarred);
    await DatabaseHelper.instance.updateMission(updated);
    if (mounted) context.read<MissionProvider>().updateMission(updated);
  }

  void _showMissionDetails(Mission mission) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _MissionDetailSheet(
        mission: mission,
        onUpdate: (updated) async {
          await DatabaseHelper.instance.updateMission(updated);
          if (mounted) context.read<MissionProvider>().updateMission(updated);
        },
        onDelete: () async {
          await DatabaseHelper.instance.deleteMission(mission.id);
          if (mounted) {
            context.read<MissionProvider>().removeMission(mission.id);
            Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showCreateMissionDialog(BuildContext context, {Mission? editMission}) {
    final titleController = TextEditingController(text: editMission?.title ?? '');
    final descController = TextEditingController(text: editMission?.description ?? '');
    MissionPriority selectedPriority = editMission?.priority ?? MissionPriority.medium;
    DateTime? selectedDate = editMission?.dueDate;
    TimeOfDay? selectedTime = editMission?.dueDate != null && (editMission!.dueDate!.hour != 0 || editMission.dueDate!.minute != 0)
        ? TimeOfDay(hour: editMission.dueDate!.hour, minute: editMission.dueDate!.minute)
        : null;
    final isEditing = editMission != null;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final l = AppLocalizations.of(ctx);
            final th = Theme.of(ctx);
            final primary = th.colorScheme.primary;
            final textColor = th.textTheme.bodyLarge?.color ?? Colors.black;
            final mutedColor = th.textTheme.bodySmall?.color ?? Colors.grey;

            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: th.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(isEditing ? Icons.edit_rounded : Icons.add_task_rounded, color: primary, size: 24),
                        const SizedBox(width: 10),
                        Text(isEditing ? l.get('editTaskTitle') : l.get('newTaskTitle'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: Icon(Icons.close_rounded, color: mutedColor), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      autofocus: !isEditing,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l.get('taskObjective'),
                        labelText: l.get('taskTitle'),
                        labelStyle: TextStyle(color: primary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: l.get('taskDetailsHint'),
                        labelText: l.get('taskDetails'),
                        labelStyle: TextStyle(color: primary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(l.get('priorityLevel'), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: MissionPriority.values.map((priority) {
                        final selected = selectedPriority == priority;
                        final color = CuteTheme.getPriorityColor(priority.index);
                        final labels = [l.get('low'), l.get('med'), l.get('high'), l.get('critical')];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedPriority = priority),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? color.withOpacity(0.12) : th.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                              ),
                              child: Center(child: Text(labels[priority.index], style: TextStyle(color: selected ? color : mutedColor, fontSize: 12, fontWeight: FontWeight.w600))),
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
                          context: ctx,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setModalState(() => selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: th.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: selectedDate != null ? primary : mutedColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              selectedDate != null ? '${l.get('setDueDate')}: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}' : l.get('setDueDate'),
                              style: TextStyle(color: selectedDate != null ? textColor : mutedColor, fontSize: 14),
                            ),
                            if (selectedDate != null) ...[
                              const Spacer(),
                              GestureDetector(onTap: () => setModalState(() { selectedDate = null; selectedTime = null; }), child: Icon(Icons.clear_rounded, size: 18, color: mutedColor)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Time picker
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setModalState(() => selectedTime = time);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: th.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: selectedTime != null ? primary : mutedColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              selectedTime != null ? '${l.get('dueTime')}: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}' : l.get('setTime'),
                              style: TextStyle(color: selectedTime != null ? textColor : mutedColor, fontSize: 14),
                            ),
                            if (selectedTime != null) ...[
                              const Spacer(),
                              GestureDetector(onTap: () => setModalState(() => selectedTime = null), child: Icon(Icons.clear_rounded, size: 18, color: mutedColor)),
                            ],
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

                          DateTime? finalDate = selectedDate;
                          if (finalDate != null && selectedTime != null) {
                            finalDate = DateTime(finalDate.year, finalDate.month, finalDate.day, selectedTime!.hour, selectedTime!.minute);
                          }

                          if (isEditing) {
                            final updated = editMission.copyWith(
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              priority: selectedPriority,
                              dueDate: finalDate,
                            );
                            await DatabaseHelper.instance.updateMission(updated);
                            if (mounted) {
                              context.read<MissionProvider>().updateMission(updated);
                              // Schedule notification if due date set
                              if (finalDate != null) {
                                await NotificationService.instance.scheduleTaskReminder(taskId: updated.id, title: updated.title, dueDate: finalDate);
                              }
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('taskUpdated'))));
                            }
                          } else {
                            final mission = Mission(
                              title: titleController.text.trim(),
                              description: descController.text.trim(),
                              priority: selectedPriority,
                              dueDate: finalDate,
                            );
                            await DatabaseHelper.instance.insertMission(mission);
                            if (mounted) {
                              context.read<MissionProvider>().addMission(mission);
                              // Schedule notification if due date set
                              if (finalDate != null) {
                                await NotificationService.instance.scheduleTaskReminder(taskId: mission.id, title: mission.title, dueDate: finalDate);
                              }
                              Navigator.pop(ctx);
                            }
                          }
                        },
                        icon: Icon(isEditing ? Icons.save_rounded : Icons.add_task_rounded, size: 20),
                        label: Text(isEditing ? l.get('editTask') : l.get('createTask')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ===== MISSION DETAIL SHEET =====
class _MissionDetailSheet extends StatefulWidget {
  final Mission mission;
  final Function(Mission) onUpdate;
  final VoidCallback onDelete;

  const _MissionDetailSheet({required this.mission, required this.onUpdate, required this.onDelete});

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
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.assignment_rounded, color: primary, size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(l.get('taskDetailsTitle'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold))),
              // Edit button
              IconButton(
                icon: Icon(Icons.edit_rounded, color: primary, size: 22),
                onPressed: () {
                  Navigator.pop(context);
                  // Find parent state to call create dialog in edit mode
                  final parentState = context.findAncestorStateOfType<_MissionsScreenState>();
                  parentState?._showCreateMissionDialog(context, editMission: _mission);
                },
              ),
              IconButton(icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 22), onPressed: widget.onDelete),
              IconButton(icon: Icon(Icons.close_rounded, color: mutedColor), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text(_mission.title, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          if (_mission.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_mission.description, style: TextStyle(color: mutedColor, fontSize: 14, height: 1.5)),
          ],
          if (_mission.dueDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: primary),
                const SizedBox(width: 6),
                Text(
                  _formatFullDate(_mission.dueDate!),
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(l.get('updateStatus'), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatusButton(l.get('pending'), MissionStatus.pending, Colors.orange, theme),
              const SizedBox(width: 8),
              _buildStatusButton(l.get('active'), MissionStatus.inProgress, primary, theme),
              const SizedBox(width: 8),
              _buildStatusButton(l.get('done'), MissionStatus.completed, Colors.green, theme),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, MissionStatus status, Color color, ThemeData theme) {
    final selected = _mission.status == status;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mission = _mission.copyWith(status: status, completedAt: status == MissionStatus.completed ? DateTime.now() : null);
          });
          widget.onUpdate(_mission);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
          ),
          child: Center(child: Text(label, style: TextStyle(color: selected ? color : mutedColor, fontSize: 13, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final d = '${date.day}/${date.month}/${date.year}';
    if (date.hour == 0 && date.minute == 0) return d;
    return '$d ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
