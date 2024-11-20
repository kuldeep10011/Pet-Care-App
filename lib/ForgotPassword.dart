import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Updated background color
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.green, // Updated to Green[600]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock with key image at the top
                Image.asset(
                  'assets/images/lock.png', // Ensure you have this image in your assets folder
                  height: 120,
                ),
                const SizedBox(height: 30),

                // Text with instructions
                Text(
                  "Reset your password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600], // Updated to Green[600]
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter your registered email address below to receive a password reset link.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Email input field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.blueGrey[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.green[100], // Updated to Green[100]
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Send Reset Link button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _sendPasswordResetEmail();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor:
                          Colors.green[600], // Updated to Green[600]
                    ),
                    child: Text(
                      "Send Reset Link",
                      style: TextStyle(
                          fontSize: 18, color: Colors.black), // Black text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog(context, 'Error', 'Please enter an email address.');
      return;
    }

    final RegExp emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegExp.hasMatch(email)) {
      _showErrorDialog(context, 'Error', 'Invalid email address format.');
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('UserRegistration')
          .where('Email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        _showErrorDialog(
            context, 'Error', 'This email address is not registered.');
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      _showSuccessDialog(context, 'Check your email',
          'A password reset link has been sent to your email.');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Error', e.message ?? 'An error occurred.');
    }
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Navigate back to login page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
