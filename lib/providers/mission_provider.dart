import 'package:flutter/material.dart';
import '../models/mission.dart';

class MissionProvider extends ChangeNotifier {
  List<Mission> _missions = [];
  List<Mission> _filteredMissions = [];
  String _searchQuery = '';
  MissionStatus? _statusFilter;
  MissionPriority? _priorityFilter;
  bool _showStarredOnly = false;

  List<Mission> get missions => _filteredMissions.isEmpty && _searchQuery.isEmpty && _statusFilter == null && _priorityFilter == null && !_showStarredOnly
      ? _missions
      : _filteredMissions;

  List<Mission> get allMissions => _missions;
  String get searchQuery => _searchQuery;
  MissionStatus? get statusFilter => _statusFilter;
  MissionPriority? get priorityFilter => _priorityFilter;
  bool get showStarredOnly => _showStarredOnly;

  void setMissions(List<Mission> missions) {
    _missions = missions;
    _applyFilters();
    notifyListeners();
  }

  void addMission(Mission mission) {
    _missions.insert(0, mission);
    _applyFilters();
    notifyListeners();
  }

  void updateMission(Mission mission) {
    final index = _missions.indexWhere((m) => m.id == mission.id);
    if (index != -1) {
      _missions[index] = mission;
      _applyFilters();
      notifyListeners();
    }
  }

  void removeMission(String id) {
    _missions.removeWhere((m) => m.id == id);
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(MissionStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setPriorityFilter(MissionPriority? priority) {
    _priorityFilter = priority;
    _applyFilters();
    notifyListeners();
  }

  void setStarredOnly(bool value) {
    _showStarredOnly = value;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _showStarredOnly = false;
    _filteredMissions = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMissions = _missions.where((mission) {
      if (_searchQuery.isNotEmpty &&
          !mission.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !mission.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_statusFilter != null && mission.status != _statusFilter) {
        return false;
      }
      if (_priorityFilter != null && mission.priority != _priorityFilter) {
        return false;
      }
      if (_showStarredOnly && !mission.isStarred) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Mission> getMissionsForDate(DateTime date) {
    return _missions.where((m) {
      if (m.dueDate == null) return false;
      return m.dueDate!.year == date.year &&
          m.dueDate!.month == date.month &&
          m.dueDate!.day == date.day;
    }).toList();
  }

  Map<String, int> getStats() {
    return {
      'total': _missions.length,
      'completed': _missions.where((m) => m.status == MissionStatus.completed).length,
      'pending': _missions.where((m) => m.status == MissionStatus.pending).length,
      'inProgress': _missions.where((m) => m.status == MissionStatus.inProgress).length,
      'starred': _missions.where((m) => m.isStarred).length,
    };
  }
}
