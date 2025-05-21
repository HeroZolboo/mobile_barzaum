import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab9/user.dart';
import 'user.dart';
import 'test_list_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    required this.isDarkMode,
    required this.onThemeChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          Row(
            children: [
              Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
              Icon(Icons.dark_mode),
              SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// --- Notice Section ---
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('notices')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return SizedBox();
              final notice = docs.first['text'] ?? '';
              return Card(
                color: Colors.yellow[100],
                margin: EdgeInsets.all(16),
                child: ListTile(
                  leading: Icon(Icons.announcement, color: Colors.orange),
                  title: Text('Notice'),
                  subtitle: Text(notice),
                ),
              );
            },
          ),
          SizedBox(height: 24),

          /// --- Test Packages Section ---
          Row(
            children: [
              Text(
                'Test Packages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('tests')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No test packages available.'));
                }

                final tests = snapshot.data!.docs;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tests.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final data = tests[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'No Title';
                    final date = (data['createdAt'] as Timestamp?)?.toDate();
                    final price = data['price'] ?? 'Free';
                    final available = data['available'] ?? true;
                    final participants = data['participants'] ?? 0;

                    return Container(
                      width: 220,
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Date: ${date != null ? "${date.year}-${date.month}-${date.day}" : "Unknown"}',
                              ),
                              Text('Price: $price'),
                              Text('Available: ${available ? "Yes" : "No"}'),
                              Text('Participants: $participants'),
                              Spacer(),
                              ElevatedButton(
                                onPressed: available ? () {} : null,
                                child: Text('View'),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => HomePage(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TestListPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => UserPage(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
