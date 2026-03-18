import 'dart:html' as html;
import 'package:flutter/material.dart';

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
  html.Worker? _worker;

  final String _nodeId = "browser-node-001";

  bool _isRunning = false;
  int _tasksCompleted = 0;

  String _status = "Idle";
  String _lastResult = "No tasks executed yet.";

  final List<String> _taskHistory = [];

  @override
  void dispose() {
    _worker?.terminate();
    super.dispose();
  }

  void _runSampleTask() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _status = "Executing task...";
    });

    _worker?.terminate();
    _worker = html.Worker('compute_worker.js');

    _worker!.onMessage.listen((event) {
      final data = event.data;

      setState(() {
        _isRunning = false;
        _tasksCompleted++;

        _lastResult =
            "Task ${data["taskId"]} completed → output=${data["output"]}";

        _taskHistory.insert(
            0, "Task ${data["taskId"]} → output ${data["output"]}");

        _status = "Idle";
      });
    });

    _worker!.postMessage({
      'taskId': 'task-${_tasksCompleted + 1}',
      'value': 21,
      'iterations': 100000
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
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OptiMesh Node Dashboard"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Browser Compute Node",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildStat("Node ID", _nodeId),
                    const SizedBox(width: 16),
                    _buildStat("Worker Status", _status),
                    const SizedBox(width: 16),
                    _buildStat("Tasks Completed", "$_tasksCompleted"),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? null : _runSampleTask,
                      child: const Text("Execute Task"),
                    ),
                    const SizedBox(width: 20),
                    if (_isRunning)
                      const CircularProgressIndicator(),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Last Task Result",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_lastResult),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Task History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: _taskHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_taskHistory[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}