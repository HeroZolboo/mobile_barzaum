// Add notice to the home page of the user
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNoticePage extends StatelessWidget {
  final TextEditingController _noticeController = TextEditingController();

  AddNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Notice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noticeController,
              decoration: InputDecoration(labelText: 'Notice'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final notice = _noticeController.text.trim();
                if (notice.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('notices').add({
                    'text': notice,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add Notice'),
            ),
          ],
        ),
      ),
    );
  }
}
