import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab9/login_page.dart';
import 'create_test_page.dart';
import 'add_notice.dart';

class AdminPage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  AdminPage({
    Key? key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  }) : super(key: key);

  void deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  void updateUser(
    String uid,
    String name,
    String age,
    String role,
    String phoneNumber,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'age': int.tryParse(age) ?? 0,
      'role': role,
      'phone_number': phoneNumber,
    });
  }

  Future<void> addUser(
    String name,
    String age,
    String email,
    String role,
    String password,
    String phoneNumber,
  ) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'name': name,
          'age': int.tryParse(age) ?? 0,
          'email': email,
          'role': role,
          'phone_number': phoneNumber,
        });
  }

  void showEdit(
    BuildContext context,
    String uid,
    String name,
    String age,
    String role,
    String phoneNumber,
  ) {
    final nameCon = TextEditingController(text: name);
    final ageCon = TextEditingController(text: age);
    final roleCon = TextEditingController(text: role);
    final phoneCon = TextEditingController(text: phoneNumber);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCon,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: ageCon,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: roleCon,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                TextField(
                  controller: phoneCon,
                  decoration: InputDecoration(labelText: 'Phone Number'),
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
                  final newName = nameCon.text.trim();
                  final newAge = ageCon.text.trim();
                  final newRole = roleCon.text.trim();
                  final newPhone = phoneCon.text.trim();
                },
                child: Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        actions: [Switch(value: isDark, onChanged: onThemeChanged)],
      ),
      body: Column(
        children: [
          // Top buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.group),
                    label: Text('Users'),
                    onPressed: () {}, // Users tab is default
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.person_add),
                    label: Text('Add User'),
                    onPressed: () => _showAddUserDialog(context),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.assignment),
                    label: Text('Create Test'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateTestPage()),
                      );
                    },
                  ),

                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_alert_outlined),
                    label: Text('Add Notice'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddNoticePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text('No users found'));

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final user = docs[index];
                    final data = user.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    data['pfp_url'] !=
                                                null && // Check if URL is not empty
                                            data['pfp_url']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(data['pfp_url'])
                                        : null,
                                child:
                                    (data['pfp_url'] == null ||
                                            data['pfp_url']
                                                .toString()
                                                .isEmpty) //
                                        ? Icon(Icons.person, size: 28)
                                        : null,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  data['name'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Text('Email: ${data['email']}'),
                              Text('Role: ${data['role']}'),
                              Text('Phone: ${data['phone_number'] ?? ''}'),
                              Text('Age: ${data['age']}'),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      showEdit(
                                        context,
                                        user.id,
                                        data['name'] ?? '',
                                        data['age'].toString(),
                                        data['role'] ?? '',
                                        data['phone_number'] ?? '',
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteUser(user.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        },
        child: Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final emailController = TextEditingController();
    final roleController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add New User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: roleController,
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final age = ageController.text.trim();
                  final email = emailController.text.trim();
                  final role = roleController.text.trim();
                  final password = passwordController.text.trim();
                  final phone = phoneController.text.trim();

                  if ([
                    name,
                    age,
                    email,
                    role,
                    password,
                    phone,
                  ].any((e) => e.isEmpty))
                    return;

                  try {
                    await addUser(name, age, email, role, password, phone);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }
}
