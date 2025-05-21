import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin.dart';
import 'user.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isLogin = false;
  final nameCon = TextEditingController();
  final ageCon = TextEditingController();
  final emailCon = TextEditingController();
  final passwordCon = TextEditingController();

  // Товчийн өнгөний хувьсагчид
  final Color primaryColor = Colors.deepPurple; // гол өнгө
  final Color secondaryColor = Colors.amber;   // хоёрдогч өнгө
  final Color backgroundColor = Color(0xFFF0F0F0); // хүндэтгэлийн арын өнгө
  final Color inputFillColor = Colors.white;   // текст талбарын арын өнгө
  final Color buttonTextColor = Colors.white;  // товчийн текстийн өнгө
  final Color linkColor = Colors.blueAccent;   // холбоос текстийн өнгө

  void submit() async {
    final name = nameCon.text.trim();
    final age = ageCon.text.trim();
    final email = emailCon.text.trim();
    final password = passwordCon.text.trim();

    try {
      if (isLogin) {
        final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = userCred.user!.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final role = doc.data()?['role'] ?? 'user';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminPage(
                onThemeChanged: (bool value) {
                  // dark mode өөрчлөлтийн үйлдэл
                },
                currentThemeMode: ThemeMode.light,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserPage(
                isDarkMode: false,
                onThemeChanged: (bool value) {
                  // dark mode өөрчлөх үйлдэл
                },
              ),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successfully")),
        );
      } else {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'age': int.tryParse(age) ?? 0,
          'email': email,
          'role': 'user',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // арын өнгө
      appBar: AppBar(
        backgroundColor: primaryColor, // AppBar гол өнгө
        title: Text(isLogin ? "Login" : "Register"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (!isLogin) ...[
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: inputFillColor,
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: nameCon,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Age',
                filled: true,
                fillColor: inputFillColor,
                labelStyle: TextStyle(color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: secondaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: ageCon,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
          ],
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: inputFillColor,
              labelStyle: TextStyle(color: primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: emailCon,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              filled: true,
              fillColor: inputFillColor,
              labelStyle: TextStyle(color: primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: passwordCon,
            obscureText: true,
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                isLogin = !isLogin;
              });
            },
            child: Text(
              isLogin ? "Don't have an account? Register now" : "Already have an account? Login",
              style: TextStyle(color: linkColor, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isLogin ? "Login" : "Register",
              style: TextStyle(color: buttonTextColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
