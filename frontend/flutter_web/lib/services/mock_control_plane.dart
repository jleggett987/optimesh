import '../models/task_model.dart';

class MockControlPlane {
  int _taskCounter = 0;

  String registerNode() {
    return 'browser-node-001';
  }

  OptiMeshTask fetchNextTask(String nodeId) {
    _taskCounter++;

    return OptiMeshTask(
      taskId: 'task-$_taskCounter',
      taskType: 'sample-compute',
      value: 21,
      iterations: 100000,
      maxDurationMs: 5000,
    );
  }

  Map<String, dynamic> submitResult({
    required String nodeId,
    required String taskId,
    required int output,
  }) {
    return {
      'accepted': true,
      'nodeId': nodeId,
      'taskId': taskId,
      'output': output,
      'status': 'completed',
    };
  }
}