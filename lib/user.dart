import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'test_list_page.dart';
import 'score_history.dart';

class UserPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  UserPage({required this.isDarkMode, required this.onThemeChanged});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  void showEdit(
    BuildContext context,
    String uid,
    String name,
    String age,
    String phoneNumber,
  ) {
    final nameController = TextEditingController(text: name);
    final ageController = TextEditingController(text: age);
    final phoneController = TextEditingController(text: phoneNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Edit User',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({
                'name': nameController.text.trim(),
                'age': int.tryParse(ageController.text.trim()) ?? 0,
                'phone_number': phoneController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isDarkMode ? ThemeData.dark() : ThemeData.light();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text("User Page"),
          actions: [
            Row(
              children: [
                Icon(Icons.light_mode),
                Switch(
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeChanged,
                ),
                Icon(Icons.dark_mode),
              ],
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Хэрэглэгчийн мэдээлэл олдсонгүй.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${data['name']}'),
                  Text('Age: ${data['age']}'),
                  Text('Email: ${data['email']}'),
                  Text('Phone: ${data['phone_number']}'),
                  Text('Role: ${data['role']}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showEdit(
                            context,
                            currentUser?.uid ?? '',
                            data['name'] ?? '',
                            data['age'].toString(),
                            data['phone_number'] ?? '',
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TestListPage()),
                      );
                    },
                    child: Text("View Tests"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ScoreHistoryPage()),
                      );
                    },
                    child: Text("View Score History"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}