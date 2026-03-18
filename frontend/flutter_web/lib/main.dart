// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
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
  bool _isRunning = false;
  String _status = 'Idle';
  String _result = 'No task executed yet.';

  @override
  void dispose() {
    _worker?.terminate();
    super.dispose();
  }

  void _runSampleTask() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _status = 'Running sample compute task...';
      _result = 'Waiting for result...';
    });

    _worker?.terminate();
    _worker = html.Worker('compute_worker.js');

    _worker!.onMessage.listen((event) {
      final data = event.data;

      setState(() {
        _isRunning = false;
        _status = 'Task completed';
        _result =
            'Task ${data["taskId"]}: output=${data["output"]}, iterations=${data["iterations"]}, status=${data["status"]}';
      });
    });

    _worker!.postMessage({
      'taskId': 'task-001',
      'value': 21,
      'iterations': 100000,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptiMesh'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opt-in Distributed Browser Compute',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This demo shows a bounded compute task executed in a browser Web Worker and returned to the Flutter Web client.',
                    ),
                    const SizedBox(height: 24),
                    Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isRunning ? null : _runSampleTask,
                            child: const Text('Run Sample Task'),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _status,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Result',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Node Status',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Node ID: browser-node-001"),
                          const SizedBox(height: 8),
                          Text("Status: $_status"),
                          const SizedBox(height: 8),
                          Text("Last Task Result: $_result"),
                        ],
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
                      child: Text(_result),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}