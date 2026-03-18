class OptiMeshTask {
  final String taskId;
  final String taskType;
  final int value;
  final int iterations;
  final int maxDurationMs;

  const OptiMeshTask({
    required this.taskId,
    required this.taskType,
    required this.value,
    required this.iterations,
    required this.maxDurationMs,
  });
}