import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'models/task_model.dart';
import 'services/mock_control_plane.dart';

void main() {
  runApp(const OptiMeshApp());
}

class OptiMeshApp extends StatelessWidget {
  const OptiMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiMesh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const OptiMeshHomePage(),
    );
  }
}

class OptiMeshHomePage extends StatefulWidget {
  const OptiMeshHomePage({super.key});

  @override
  State<OptiMeshHomePage> createState() => _OptiMeshHomePageState();
}

class _OptiMeshHomePageState extends State<OptiMeshHomePage> {
  final MockControlPlane _controlPlane = MockControlPlane();
  html.Worker? _worker;

  late final String _nodeId;

  bool _isRunning = false;
  int _tasksCompleted = 0;

  String _status = 'Idle';
  String _lastResult = 'No tasks executed yet.';
  String _lastTaskId = 'None';
  String _lastTaskType = 'None';

  final List<String> _taskHistory = [];

  @override
  void initState() {
    super.initState();
    _nodeId = _controlPlane.registerNode();
  }

  @override
  void dispose() {
    _worker?.terminate();
    super.dispose();
  }

  void _executeNextTask() {
    if (_isRunning) return;

    final OptiMeshTask task = _controlPlane.fetchNextTask(_nodeId);

    setState(() {
      _isRunning = true;
      _status = 'Executing ${task.taskId}...';
      _lastTaskId = task.taskId;
      _lastTaskType = task.taskType;
    });

    _worker?.terminate();
    _worker = html.Worker('compute_worker.js');

    _worker!.onMessage.listen((event) {
      final data = event.data;
      final int output = data['output'] as int;

      final submission = _controlPlane.submitResult(
        nodeId: _nodeId,
        taskId: task.taskId,
        output: output,
      );

      setState(() {
        _isRunning = false;
        _tasksCompleted++;
        _status = 'Idle';
        _lastResult =
            'Task ${submission["taskId"]} accepted with output=${submission["output"]}';
        _taskHistory.insert(
          0,
          '${submission["taskId"]} • ${task.taskType} • output=${submission["output"]}',
        );
      });
    });

    _worker!.postMessage({
      'taskId': task.taskId,
      'value': task.value,
      'iterations': task.iterations,
    });
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiMesh Node Dashboard'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browser Compute Node',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simulated control-plane flow: register node, fetch bounded task, execute in worker, and submit result.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStat('Node ID', _nodeId),
                    const SizedBox(width: 16),
                    _buildStat('Worker Status', _status),
                    const SizedBox(width: 16),
                    _buildStat('Tasks Completed', '$_tasksCompleted'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? null : _executeNextTask,
                      child: const Text('Fetch and Execute Task'),
                    ),
                    const SizedBox(width: 20),
                    if (_isRunning) const CircularProgressIndicator(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoCard('Last Task ID', _lastTaskId),
                const SizedBox(height: 16),
                _buildInfoCard('Last Task Type', _lastTaskType),
                const SizedBox(height: 16),
                _buildInfoCard('Last Task Result', _lastResult),
                const SizedBox(height: 24),
                const Text(
                  'Task History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (_taskHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No tasks executed yet.'),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: _taskHistory.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.memory),
                        title: Text(_taskHistory[index]),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}