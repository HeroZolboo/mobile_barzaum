import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  final String testId;
  const AddQuestionPage({super.key, required this.testId});

  @override
  State<AddQuestionPage> createState() => AddQuestionPageState();
}

class AddQuestionPageState extends State<AddQuestionPage> {
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  void addQuestion() async {
    final question = questionController.text.trim();
    final correctAnswer = answerController.text.trim();
    final options =
        optionControllers
            .map((c) => c.text.trim())
            .where((o) => o.isNotEmpty)
            .toList();

    if (question.isNotEmpty && correctAnswer.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('tests')
          .doc(widget.testId)
          .collection('questions')
          .add({
            'question': question,
            'correctAnswer': correctAnswer,
            'options': options,
            'createdAt': FieldValue.serverTimestamp(),
          });

      questionController.clear();
      answerController.clear();
      for (var c in optionControllers) {
        c.clear();
      }
    }
  }

  void editQuestion(
    String questionId,
    String currentQ,
    String currentA,
    List<dynamic> currentOptions,
  ) {
    final qController = TextEditingController(text: currentQ);
    final aController = TextEditingController(text: currentA);
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < currentOptions.length ? currentOptions[i] : '',
      ),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Question"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: qController,
                    decoration: const InputDecoration(labelText: 'Question'),
                  ),
                  TextField(
                    controller: aController,
                    decoration: const InputDecoration(labelText: 'Answer'),
                  ),
                  ...List.generate(
                    4,
                    (i) => TextField(
                      controller: optionControllers[i],
                      decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newOptions =
                      optionControllers
                          .map((c) => c.text.trim())
                          .where((o) => o.isNotEmpty)
                          .toList();
                  await FirebaseFirestore.instance
                      .collection('tests')
                      .doc(widget.testId)
                      .collection('questions')
                      .doc(questionId)
                      .update({
                        'question': qController.text.trim(),
                        'correctAnswer': aController.text.trim(),
                        'options': newOptions,
                      });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void deleteQuestion(String questionId) async {
    await FirebaseFirestore.instance
        .collection('tests')
        .doc(widget.testId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final questionsRef = FirebaseFirestore.instance
        .collection('tests')
        .doc(widget.testId)
        .collection('questions')
        .orderBy('createdAt', descending: false);

    return Scaffold(
      appBar: AppBar(title: Text('Questions for Test: ${widget.testId}')),
      body: Column(
        children: [
          // Input fields
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                ),
                ...List.generate(
                  4,
                  (i) => TextField(
                    controller: optionControllers[i],
                    decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addQuestion,
                  child: const Text('Add Question'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Live question list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: questionsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No questions added yet.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final questionId = docs[index].id;
                    final options = (data['options'] as List<dynamic>? ?? []);

                    return ListTile(
                      title: Text(data['question'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Answer: ${data['correctAnswer'] ?? ''}'),
                          if (options.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Options: ${options.join(", ")}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed:
                                () => editQuestion(
                                  questionId,
                                  data['question'] ?? '',
                                  data['correctAnswer'] ?? '',
                                  options,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteQuestion(questionId),
                          ),
                        ],
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
  }
}
