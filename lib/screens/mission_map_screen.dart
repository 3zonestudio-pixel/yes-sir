import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mission.dart';
import '../providers/mission_provider.dart';
import '../services/database_helper.dart';
import '../theme/military_theme.dart';
import '../widgets/military_widgets.dart';

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
          const Divider(height: 1, color: MilitaryTheme.surfaceLight),
          _buildDayHeader(),
          Expanded(child: _buildDayMissions()),
        ],
      ),
    );
  }

  Widget _buildCalendar(MissionProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          defaultTextStyle: const TextStyle(color: MilitaryTheme.textPrimary),
          weekendTextStyle: const TextStyle(color: MilitaryTheme.textSecondary),
          outsideTextStyle: const TextStyle(color: MilitaryTheme.textMuted),
          todayDecoration: BoxDecoration(
            color: MilitaryTheme.militaryGreen.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: MilitaryTheme.accentGreen, width: 1),
          ),
          todayTextStyle: const TextStyle(
            color: MilitaryTheme.accentGreen,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: const BoxDecoration(
            color: MilitaryTheme.militaryGreen,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: MilitaryTheme.goldAccent,
            fontWeight: FontWeight.bold,
          ),
          markerDecoration: const BoxDecoration(
            color: MilitaryTheme.goldAccent,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          cellMargin: const EdgeInsets.all(4),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: MilitaryTheme.goldAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(
            color: MilitaryTheme.goldAccent,
            fontSize: 12,
          ),
          titleCentered: true,
          titleTextStyle: const TextStyle(
            color: MilitaryTheme.goldAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: MilitaryTheme.goldAccent),
          rightChevronIcon: const Icon(Icons.chevron_right, color: MilitaryTheme.goldAccent),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: MilitaryTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: TextStyle(
            color: MilitaryTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader() {
    final now = DateTime.now();
    final isToday = isSameDay(_selectedDay, now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isToday ? Icons.today : Icons.calendar_today,
            color: MilitaryTheme.goldAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isToday
                ? 'TODAY\'S MISSIONS'
                : '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
            style: const TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MilitaryTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedDayMissions.length} mission${_selectedDayMissions.length != 1 ? 's' : ''}',
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayMissions() {
    if (_selectedDayMissions.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Missions Scheduled',
        subtitle: 'This day is clear. Assign missions from the Missions tab.',
        icon: Icons.event_available,
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
    final isCompleted = mission.status == MissionStatus.completed;

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline line
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? MilitaryTheme.accentGreen
                        : MilitaryTheme.getPriorityColor(mission.priority.index),
                    border: Border.all(
                      color: isCompleted
                          ? MilitaryTheme.accentGreen
                          : MilitaryTheme.getPriorityColor(mission.priority.index),
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: MilitaryTheme.surfaceLight,
                  ),
                ),
              ],
            ),
          ),

          // Mission card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 8),
              padding: const EdgeInsets.all(12),
              decoration: MilitaryTheme.militaryCardDecoration,
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
                            fontSize: 14,
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
                  const SizedBox(height: 6),
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
