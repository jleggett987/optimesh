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

class OptiMeshHomePage extends StatelessWidget {
  const OptiMeshHomePage({super.key});

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
                  children: const [
                    Text(
                      'Opt-in Distributed Browser Compute',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'OptiMesh is a transparent distributed browser compute platform concept built with Flutter Web, Web Workers, WebAssembly, and AWS serverless infrastructure.',
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Current frontend status: initial shell created.',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
