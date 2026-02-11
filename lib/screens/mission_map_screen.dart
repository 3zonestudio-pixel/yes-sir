import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';
import '../theme/military_theme.dart';
import '../widgets/military_widgets.dart';
import '../l10n/app_localizations.dart';

class MissionMapScreen extends StatefulWidget {
  const MissionMapScreen({super.key});

  @override
  State<MissionMapScreen> createState() => _MissionMapScreenState();
}

class _MissionMapScreenState extends State<MissionMapScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Mission> _selectedDayMissions = [];

  @override
  void initState() {
    super.initState();
    _loadMissionsForDay(_selectedDay);
  }

  Future<void> _loadMissionsForDay(DateTime day) async {
    final missions = await DatabaseHelper.instance.getMissionsByDate(day);
    setState(() {
      _selectedDayMissions = missions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildCalendar(provider),
          const SizedBox(height: 4),
          _buildDayHeader(),
          Expanded(child: _buildDayMissions()),
        ],
      ),
    );
  }

  Widget _buildCalendar(MissionProvider provider) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final surface = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryText = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _loadMissionsForDay(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          eventLoader: (day) {
            return provider.getMissionsForDate(day);
          },
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: textColor),
            weekendTextStyle: TextStyle(color: secondaryText),
            outsideTextStyle: TextStyle(color: mutedColor),
            todayDecoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 1.5),
            ),
            todayTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
            selectedDecoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            markerDecoration: BoxDecoration(color: secondary, shape: BoxShape.circle),
            markerSize: 6,
            markersMaxCount: 3,
            cellMargin: const EdgeInsets.all(4),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            formatButtonDecoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            formatButtonTextStyle: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
            titleCentered: true,
            titleTextStyle: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: primary),
            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: primary),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final now = DateTime.now();
    final isToday = isSameDay(_selectedDay, now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(isToday ? Icons.today_rounded : Icons.calendar_today_rounded, color: primary, size: 18),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) {
              final l = AppLocalizations.of(context);
              return Text(
                isToday ? l.get('todayTasks') : '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
              );
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Builder(
              builder: (context) {
                final l = AppLocalizations.of(context);
                return Text(
                  '${_selectedDayMissions.length} ${_selectedDayMissions.length != 1 ? l.get('tasks') : l.get('task')}',
                  style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMissions() {
    if (_selectedDayMissions.isEmpty) {
      final l = AppLocalizations.of(context);
      return EmptyStateWidget(
        title: l.get('noTasksScheduled2'),
        subtitle: l.get('noTasksScheduledSub'),
        icon: Icons.event_available_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _selectedDayMissions.length,
      itemBuilder: (context, index) {
        final mission = _selectedDayMissions[index];
        return _buildMissionTimelineCard(mission, index);
      },
    );
  }

  Widget _buildMissionTimelineCard(Mission mission, int index) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final isCompleted = mission.status == MissionStatus.completed;
    final priorityColor = MilitaryTheme.getPriorityColor(mission.priority.index);

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? primary : priorityColor.withOpacity(0.2),
                    border: Border.all(color: isCompleted ? primary : priorityColor, width: 2),
                  ),
                  child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 8) : null,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [priorityColor.withOpacity(0.3), priorityColor.withOpacity(0.05)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: TextStyle(
                            color: isCompleted ? mutedColor : textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      PriorityBadge(priorityIndex: mission.priority.index, compact: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(statusIndex: mission.status.index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
