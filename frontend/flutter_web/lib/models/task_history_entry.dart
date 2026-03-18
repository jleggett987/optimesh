class TaskHistoryEntry {
  final String taskId;
  final String taskType;
  final int samplesProcessed;
  final double estimate;
  final bool accepted;
  final DateTime completedAt;

  const TaskHistoryEntry({
    required this.taskId,
    required this.taskType,
    required this.samplesProcessed,
    required this.estimate,
    required this.accepted,
    required this.completedAt,
  });

  String get statusLabel => accepted ? 'Accepted' : 'Rejected';

  String get formattedTimestamp {
    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');
    final second = completedAt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}