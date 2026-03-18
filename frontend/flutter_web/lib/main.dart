import 'dart:html' as html;
import 'package:flutter/material.dart';

import 'models/task_history_entry.dart';
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

  bool _nodeActive = false;
  bool _isRunning = false;

  int _tasksCompleted = 0;
  int _totalSamplesProcessed = 0;

  double _executionLoad = 0.08;
  double _lastEstimate = 0.0;
  double _rollingEstimate = 0.0;

  String _status = 'Idle';
  String _lastResult = 'No tasks executed yet.';

  OptiMeshTask? _currentTask;

  final List<TaskHistoryEntry> _taskHistory = [];
  final List<String> _activityFeed = [];
  final List<double> _estimateHistory = [];

  static const double _piReference = 3.141593;
  static const int _maxEstimateHistory = 30;

  @override
  void initState() {
    super.initState();
    _nodeId = _controlPlane.registerNode();
    _addActivity('Node registered: $_nodeId');
  }

  @override
  void dispose() {
    _worker?.terminate();
    super.dispose();
  }

  void _addActivity(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    _activityFeed.insert(0, '[$time] $message');

    if (_activityFeed.length > 20) {
      _activityFeed.removeLast();
    }
  }

  void _startNode() {
    if (_nodeActive) return;

    setState(() {
      _nodeActive = true;
      _status = 'Node Active';
      _executionLoad = 0.18;
    });

    _addActivity('Node started');

    if (!_isRunning) {
      _executeNextTask();
    }
  }

  void _stopNode() {
    setState(() {
      _nodeActive = false;

      if (!_isRunning) {
        _status = 'Node Stopped';
      }

      _executionLoad = _isRunning ? 0.72 : 0.05;
    });

    _addActivity('Node stopped');
  }

  void _executeNextTask() {
    if (_isRunning) return;

    final task = _controlPlane.fetchNextTask(_nodeId);

    setState(() {
      _isRunning = true;
      _currentTask = task;
      _status = 'Executing ${task.taskId}...';
      _executionLoad = 0.82;
    });

    _addActivity('Fetched ${task.taskId}');
    _addActivity('Started ${task.taskId}');

    _worker?.terminate();
    _worker = html.Worker('compute_worker.js');

    _worker!.onMessage.listen((event) {
      final data = event.data;

      final int samplesProcessed = data['samplesProcessed'] as int;
      final double estimate = (data['estimate'] as num).toDouble();

      final submission = _controlPlane.submitResult(
        nodeId: _nodeId,
        taskId: task.taskId,
        output: (estimate * 1000000).round(),
      );

      final bool accepted = submission['accepted'] as bool;

      setState(() {
        _isRunning = false;
        _tasksCompleted++;
        if (accepted) {
        }

        _totalSamplesProcessed += samplesProcessed;
        _lastEstimate = estimate;

        if (_rollingEstimate == 0.0) {
          _rollingEstimate = estimate;
        } else {
          _rollingEstimate =
              ((_rollingEstimate * (_tasksCompleted - 1)) + estimate) /
                  _tasksCompleted;
        }

        _estimateHistory.add(estimate);
        if (_estimateHistory.length > _maxEstimateHistory) {
          _estimateHistory.removeAt(0);
        }

        _status = _nodeActive ? 'Node Active' : 'Idle';
        _executionLoad = _nodeActive ? 0.22 : 0.08;

        _lastResult =
            'Task ${task.taskId} accepted • local π estimate=${estimate.toStringAsFixed(6)} • samples=$samplesProcessed';

        _taskHistory.insert(
          0,
          TaskHistoryEntry(
            taskId: task.taskId,
            taskType: 'monte-carlo-pi',
            samplesProcessed: samplesProcessed,
            estimate: estimate,
            accepted: accepted,
            completedAt: DateTime.now(),
          ),
        );
      });

      _addActivity('Completed ${task.taskId}');
      _addActivity(
        'Estimate from ${task.taskId}: ${estimate.toStringAsFixed(6)}',
      );
      _addActivity(
        '${task.taskId} ${accepted ? "accepted" : "rejected"}',
      );

      if (_nodeActive) {
        Future.microtask(_executeNextTask);
      }
    });

    _worker!.postMessage({
      'taskId': task.taskId,
      'value': task.value,
      'iterations': task.iterations,
    });
  }

  Color _statusColor() {
    if (_isRunning) return Colors.orange;
    if (_nodeActive) return Colors.green;
    return Colors.grey;
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 14),
          Text(label),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionLoadCard() {
    final percent = (_executionLoad * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Execution Load',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _executionLoad,
          minHeight: 12,
        ),
        const SizedBox(height: 6),
        Text('$percent% node activity'),
      ],
    );
  }

  Widget _buildCurrentTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: _currentTask == null
          ? const Text('No task has been assigned yet.')
          : Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMiniTaskStat('Task ID', _currentTask!.taskId),
                _buildMiniTaskStat('Task Type', 'monte-carlo-pi'),
                _buildMiniTaskStat(
                  'Samples',
                  '${_currentTask!.iterations}',
                ),
                _buildMiniTaskStat(
                  'Max Duration',
                  '${_currentTask!.maxDurationMs} ms',
                ),
              ],
            ),
    );
  }

  Widget _buildMiniTaskStat(String label, String value) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live π Estimate Trend',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _estimateHistory.isEmpty
                ? 'Run tasks to begin plotting Monte Carlo estimates.'
                : 'Recent task estimates compared to π reference (${_piReference.toStringAsFixed(6)}).',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _estimateHistory.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Text('No chart data yet.'),
                  )
                : CustomPaint(
                    painter: EstimateChartPainter(
                      estimates: _estimateHistory,
                      piReference: _piReference,
                    ),
                    child: Container(),
                  ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                'Last: ${_lastEstimate == 0 ? "N/A" : _lastEstimate.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Rolling: ${_rollingEstimate == 0 ? "N/A" : _rollingEstimate.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text(
                'Reference: 3.141593',
                style: TextStyle(fontWeight: FontWeight.w600),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (_taskHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No tasks executed yet.'),
            )
          else
            ListView.separated(
              itemCount: _taskHistory.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final entry = _taskHistory[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      entry.accepted ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: entry.accepted ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.taskId} • ${entry.taskType}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'π estimate: ${entry.estimate.toStringAsFixed(6)} • Samples: ${entry.samplesProcessed} • ${entry.statusLabel} • ${entry.formattedTimestamp}',
                          ),
                        ],
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

  Widget _buildActivityFeed() {
    if (_activityFeed.isEmpty) {
      return const Text('No activity yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _activityFeed
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(entry),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiMesh Monte Carlo Dashboard'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: _nodeActive ? null : _startNode,
                      child: const Text('Start Node'),
                    ),
                    ElevatedButton(
                      onPressed: _nodeActive ? _stopNode : null,
                      child: const Text('Stop Node'),
                    ),
                    ElevatedButton(
                      onPressed: _isRunning ? null : _executeNextTask,
                      child: const Text('Run One Task'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                      icon: Icons.settings,
                      label: 'Worker Status',
                      value: _status,
                      valueColor: _statusColor(),
                    ),
                    _buildStatCard(
                      icon: Icons.check,
                      label: 'Tasks Completed',
                      value: '$_tasksCompleted',
                    ),
                    _buildStatCard(
                      icon: Icons.analytics,
                      label: 'Samples Processed',
                      value: '$_totalSamplesProcessed',
                    ),
                    _buildStatCard(
                      icon: Icons.functions,
                      label: 'Last π Estimate',
                      value: _lastEstimate == 0
                          ? 'N/A'
                          : _lastEstimate.toStringAsFixed(6),
                    ),
                    _buildStatCard(
                      icon: Icons.public,
                      label: 'Rolling π Estimate',
                      value: _rollingEstimate == 0
                          ? 'N/A'
                          : _rollingEstimate.toStringAsFixed(6),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildExecutionLoadCard(),
                const SizedBox(height: 24),
                _buildEstimateChartCard(),
                const SizedBox(height: 24),
                const Text(
                  'Assigned Workload',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                _buildCurrentTaskCard(),
                const SizedBox(height: 24),
                const Text(
                  'Last Result',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(_lastResult),
                ),
                const SizedBox(height: 24),
                _buildTaskHistoryCard(),
                const SizedBox(height: 24),
                const Text(
                  'Activity Feed',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                _buildActivityFeed(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EstimateChartPainter extends CustomPainter {
  final List<double> estimates;
  final double piReference;

  EstimateChartPainter({
    required this.estimates,
    required this.piReference,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 20;
    final Rect chartRect = Rect.fromLTWH(
      padding,
      padding,
      size.width - (padding * 2),
      size.height - (padding * 2),
    );

    final Paint borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke;

    final Paint gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    final Paint refPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2;

    final Paint linePaint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Paint dotPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill;

    canvas.drawRect(chartRect, borderPaint);

    for (int i = 1; i < 4; i++) {
      final double y = chartRect.top + (chartRect.height * i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    if (estimates.isEmpty) return;

    final double minValue = 3.05;
    final double maxValue = 3.23;

    double mapY(double value) {
      final normalized = ((value - minValue) / (maxValue - minValue))
          .clamp(0.0, 1.0);
      return chartRect.bottom - (normalized * chartRect.height);
    }

    final double refY = mapY(piReference);
    canvas.drawLine(
      Offset(chartRect.left, refY),
      Offset(chartRect.right, refY),
      refPaint,
    );

    if (estimates.length == 1) {
      final double x = chartRect.left + chartRect.width / 2;
      final double y = mapY(estimates.first);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      return;
    }

    final Path linePath = Path();

    for (int i = 0; i < estimates.length; i++) {
      final double x = chartRect.left +
          (chartRect.width * i / (estimates.length - 1));
      final double y = mapY(estimates[i]);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < estimates.length; i++) {
      final double x = chartRect.left +
          (chartRect.width * i / (estimates.length - 1));
      final double y = mapY(estimates[i]);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    final textPainterTop = TextPainter(
      text: const TextSpan(
        text: '3.23',
        style: TextStyle(color: Colors.black54, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainterMid = TextPainter(
      text: const TextSpan(
        text: 'π',
        style: TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainterBottom = TextPainter(
      text: const TextSpan(
        text: '3.05',
        style: TextStyle(color: Colors.black54, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainterTop.paint(
      canvas,
      Offset(2, chartRect.top - 6),
    );

    textPainterMid.paint(
      canvas,
      Offset(2, refY - 8),
    );

    textPainterBottom.paint(
      canvas,
      Offset(2, chartRect.bottom - 8),
    );
  }

  @override
  bool shouldRepaint(covariant EstimateChartPainter oldDelegate) {
    return oldDelegate.estimates != estimates ||
        oldDelegate.piReference != piReference;
  }
}