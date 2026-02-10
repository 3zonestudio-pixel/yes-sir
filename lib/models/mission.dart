import 'package:uuid/uuid.dart';

enum MissionPriority { low, medium, high, critical }

enum MissionStatus { pending, inProgress, completed, failed }

enum RecurrenceType { none, daily, weekly, monthly }

class Mission {
  final String id;
  String title;
  String description;
  MissionPriority priority;
  MissionStatus status;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? completedAt;
  bool isStarred;
  String? parentId;
  RecurrenceType recurrence;
  List<String> subMissionIds;
  int orderIndex;

  Mission({
    String? id,
    required this.title,
    this.description = '',
    this.priority = MissionPriority.medium,
    this.status = MissionStatus.pending,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
    this.isStarred = false,
    this.parentId,
    this.recurrence = RecurrenceType.none,
    List<String>? subMissionIds,
    this.orderIndex = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        subMissionIds = subMissionIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isStarred': isStarred ? 1 : 0,
      'parentId': parentId,
      'recurrence': recurrence.index,
      'subMissionIds': subMissionIds.join(','),
      'orderIndex': orderIndex,
    };
  }

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      priority: MissionPriority.values[map['priority'] as int? ?? 1],
      status: MissionStatus.values[map['status'] as int? ?? 0],
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      isStarred: (map['isStarred'] as int? ?? 0) == 1,
      parentId: map['parentId'] as String?,
      recurrence:
          RecurrenceType.values[map['recurrence'] as int? ?? 0],
      subMissionIds: (map['subMissionIds'] as String?)?.isNotEmpty == true
          ? (map['subMissionIds'] as String).split(',')
          : [],
      orderIndex: map['orderIndex'] as int? ?? 0,
    );
  }

  Mission copyWith({
    String? title,
    String? description,
    MissionPriority? priority,
    MissionStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    bool? isStarred,
    String? parentId,
    RecurrenceType? recurrence,
    List<String>? subMissionIds,
    int? orderIndex,
  }) {
    return Mission(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      isStarred: isStarred ?? this.isStarred,
      parentId: parentId ?? this.parentId,
      recurrence: recurrence ?? this.recurrence,
      subMissionIds: subMissionIds ?? this.subMissionIds,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case MissionPriority.low:
        return 'LOW';
      case MissionPriority.medium:
        return 'MEDIUM';
      case MissionPriority.high:
        return 'HIGH';
      case MissionPriority.critical:
        return 'CRITICAL';
    }
  }

  String get statusLabel {
    switch (status) {
      case MissionStatus.pending:
        return 'PENDING';
      case MissionStatus.inProgress:
        return 'IN PROGRESS';
      case MissionStatus.completed:
        return 'COMPLETED';
      case MissionStatus.failed:
        return 'FAILED';
    }
  }
}
