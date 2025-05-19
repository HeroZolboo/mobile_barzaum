import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final Map<String, dynamic> scoreData;

  const ReviewPage({Key? key, required this.scoreData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String testId = scoreData['testId'];
    final Map<String, dynamic> answers = Map<String, dynamic>.from(
      scoreData['answers'] ?? {},
    );

    final int score = scoreData['score'] ?? 0;
    final int total = scoreData['total'] ?? 0;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('tests').doc(testId).get(),
      builder: (context, snapshot) {
        String testTitle = testId;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          testTitle = data['title'] ?? testId;
        }
        return Scaffold(
          appBar: AppBar(title: Text('Review: $testTitle')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Score: $score / $total',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('tests')
                          .doc(testId)
                          .collection('questions')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No questions found for this test.'),
                      );
                    }

                    final question = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: question.length,
                      itemBuilder: (context, index) {
                        final q = question[index];
                        final qData = q.data() as Map<String, dynamic>;
                        final qId = q.id;

                        final userAnswer = answers[qId] ?? 'No answer';
                        final correctAnswer = qData['correctAnswer'];
                        final isCorrect = userAnswer == correctAnswer;

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${index + 1}: ${qData['question']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your Answer: $userAnswer',
                                  style: TextStyle(
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Correct Answer: $correctAnswer',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
