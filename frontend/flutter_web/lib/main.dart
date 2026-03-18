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

  Color _statusColor() {
    if (_isRunning) {
      return Colors.orange;
    }
    return Colors.green;
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OptiMesh Browser Node',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'This dashboard simulates a distributed browser compute node that registers with a control plane, fetches bounded tasks, executes them in a Web Worker, and submits results.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isRunning ? null : _executeNextTask,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Fetch and Execute Task'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              if (_isRunning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_taskHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No tasks executed yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ListView.separated(
              itemCount: _taskHistory.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.memory, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _taskHistory[index],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 28),
                _buildSectionTitle('Node Overview'),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard(
                      icon: Icons.computer,
                      label: 'Node ID',
                      value: _nodeId,
                    ),
                    _buildStatCard(
                      icon: Icons.settings_input_component,
                      label: 'Worker Status',
                      value: _status,
                      valueColor: _statusColor(),
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Tasks Completed',
                      value: '$_tasksCompleted',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _buildSectionTitle('Execution Details'),
                const SizedBox(height: 14),
                _buildInfoCard(
                  title: 'Last Task ID',
                  value: _lastTaskId,
                  icon: Icons.tag,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Last Task Type',
                  value: _lastTaskType,
                  icon: Icons.category,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Last Task Result',
                  value: _lastResult,
                  icon: Icons.receipt_long,
                ),
                const SizedBox(height: 28),
                _buildTaskHistoryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}