import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';

  // Email regex validation
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Name validation (only alphabetic characters and spaces)
  bool isValidName(String name) {
    final RegExp nameRegex = RegExp(
      r'^[a-zA-Z\s]+$',
    );
    return nameRegex.hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Same background as Login page
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset(
                'assets/images/dog_login.png',
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                'DOG CARE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A2828), // Brown color
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '"Making Your Dog Healthier"',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.green[500], // Green color in quotes
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A2828), // Brown color
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Enter your Name',
                      prefixIcon: const Icon(Icons.person),
                      fillColor: Colors.green[100], // Green[100] background
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      floatingLabelBehavior:
                          FloatingLabelBehavior.auto, // Label behavior
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (!isValidName(value)) {
                          _nameError = 'Name should contain only alphabets.';
                        } else {
                          _nameError = '';
                        }
                      });
                    },
                  ),
                  if (_nameError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _nameError,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter your Email Id',
                      prefixIcon: const Icon(Icons.email),
                      fillColor: Colors.green[100], // Green[100] background
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      floatingLabelBehavior:
                          FloatingLabelBehavior.auto, // Label behavior
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (!isValidEmail(value)) {
                          _emailError = 'Please enter a valid email address.';
                        } else {
                          _emailError = '';
                        }
                      });
                    },
                  ),
                  if (_emailError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _emailError,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Enter your Password',
                  prefixIcon: const Icon(Icons.lock),
                  fillColor: Colors.green[100], // Green[100] background
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.auto, // Label behavior
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.length < 8) {
                      _passwordError =
                          'Password must be at least 8 characters long.';
                    } else {
                      _passwordError = '';
                    }
                  });
                },
              ),
              if (_passwordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _passwordError,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String name = _nameController.text;
                  String email = _emailController.text;
                  String password = _passwordController.text;

                  // Check if fields are valid
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('All fields are required.'),
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
                    return;
                  }

                  if (!isValidName(name)) {
                    setState(() {
                      _nameError = 'Name should contain only alphabets.';
                    });
                    return;
                  }

                  if (!isValidEmail(email)) {
                    setState(() {
                      _emailError = 'Please enter a valid email address.';
                    });
                    return;
                  }

                  if (password.length < 8) {
                    setState(() {
                      _passwordError =
                          'Password must be at least 8 characters long.';
                    });
                    return;
                  }

                  try {
                    // Create the user in Firebase Authentication
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);

                    // Save the user data in Firestore
                    await FirebaseFirestore.instance
                        .collection('UserRegistration')
                        .doc(userCredential.user!.uid)
                        .set({
                      'Name': name,
                      'Email': email,
                      'Password': password,
                    });

                    // Show success message
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Up Successful'),
                        content: const Text('You have signed up successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/home');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    // Handle Firebase Authentication or Firestore errors
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: Text('Failed to sign up. ${e.toString()}'),
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.black), // Green button text
                ),
              ),
              const SizedBox(height: 20),
              const Text('OR', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey, // Light color
                        ),
                      ),
                      TextSpan(
                        text: 'Login Here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green, // Green color
                          // Bold text
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
