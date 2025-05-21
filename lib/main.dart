import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'admin.dart';
import 'user.dart'; // Хэрэглэгчийн UI
import 'home_page.dart'; // Үндсэн хуудас

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
      ),
      themeMode: _themeMode,
      home: AuthGate(
        onThemeChanged: toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentThemeMode;

  const AuthGate({
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Scaffold(
                  body: Center(child: Text('Хэрэглэгчийн мэдээлэл олдсонгүй')),
                );
              }

              final data = userSnapshot.data!.data()! as Map<String, dynamic>;
              final role = data['role'];

              if (role == 'admin') {
                return AdminPage(
                  onThemeChanged: onThemeChanged,
                  currentThemeMode: currentThemeMode,
                );
              } else {
                return HomePage(
                  isDarkMode: currentThemeMode == ThemeMode.dark,
                  onThemeChanged: onThemeChanged,
                );
              }
            },
          );
        }

        return LoginPage();
      },
    );
  }
}
