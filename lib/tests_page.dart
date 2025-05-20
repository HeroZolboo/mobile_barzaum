import 'package:flutter/material.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock test data
    final tests = [
      {'id': '1', 'title': 'Math Test'},
      {'id': '2', 'title': 'Science Test'},
      {'id': '3', 'title': 'History Test'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Tests Page'),
      ),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index];
          return ListTile(
            title: Text(test['title']!),
            subtitle: Text('Test ID: ${test['id']}'),
            onTap: () {
              // You can navigate to a test detail page here if needed
            },
          );
        },
      ),
    );
  }
}