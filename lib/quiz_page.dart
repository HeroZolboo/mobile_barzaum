import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPage extends StatefulWidget {
  final String testId;
  QuizPage({required this.testId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QueryDocumentSnapshot> questions = [];
  Map<String, String> answers = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tests')
            .doc(widget.testId)
            .collection('questions')
            .orderBy('createdAt') // <-- match your Firestore field
            .get();

    setState(() {
      questions = snapshot.docs;
      loading = false;
    });
  }

  void submit() async {
    int score = 0;
    for (var q in questions) {
      final data = q.data() as Map<String, dynamic>;
      if (answers[q.id] == data['correctAnswer']) {
        score++;
      }
    }

    await FirebaseFirestore.instance.collection('submissions').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'testId': widget.testId,
      'answers': answers, // Save as Map<String, String>
      'score': score,
      'total': questions.length,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Test Submitted'),
            content: Text('Your score: $score / ${questions.length}'),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: ListView(
        children: [
          for (var q in questions)
            buildQuestion(q.id, q.data() as Map<String, dynamic>),
          SizedBox(height: 20),
          ElevatedButton(onPressed: submit, child: Text("Submit")),
        ],
      ),
    );
  }

  Widget buildQuestion(String id, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['question'] ?? '', style: TextStyle(fontSize: 18)),
            ...((data['options'] as List<dynamic>? ?? []).map((option) {
              return RadioListTile(
                title: Text(option),
                value: option,
                groupValue: answers[id],
                onChanged: (value) {
                  setState(() {
                    answers[id] = value.toString();
                  });
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}
