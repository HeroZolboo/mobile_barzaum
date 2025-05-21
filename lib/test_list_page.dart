import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_page.dart';
import 'score_history.dart';

class TestListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Tests")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('tests').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final tests = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index].data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.blue[50], // ✅ жагсаалтын фоны өнгө
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 12.0),
                      child: ListTile(
                        title: Text(
                          test['title'],
                          style: TextStyle(
                            color: Colors.blue[900], // ✅ гарчгийн өнгө
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Language: ${test['language']}',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(testId: tests[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScoreHistoryPage()),
                );
              },
              child: Text("View Score History"),
            ),
          ),
        ],
      ),
    );
  }
}
