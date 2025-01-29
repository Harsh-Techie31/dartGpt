import 'dart:async';
import 'package:dartgpt/screens/chat-screen.dart';
import 'package:dartgpt/screens/login-screen.dart'; // Import the Login Page
import 'package:dartgpt/services/auths.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;
  String _errorMessage = "";
  bool _obscureText = true;
  final List<String> phrases = [
    "Let's chat",
    "Let's explore",
    "Let's collaborate",
    "ChatGPT"
  ];
  String _currentText = "";
  int _phraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    while (_phraseIndex < phrases.length) {
      String phrase = phrases[_phraseIndex];

      // Typing effect (Ensure text is white while adding letters)
      for (int i = 0; i <= phrase.length; i++) {
        setState(() {
          _currentText = phrase.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await Future.delayed(const Duration(seconds: 2)); // Hold full text

      // Erasing effect (Ensure text remains white while deleting letters)
      if (_phraseIndex < phrases.length - 1) {
        for (int i = phrase.length; i >= 0; i--) {
          setState(() {
            _currentText = phrase.substring(0, i);
          });
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      _phraseIndex++;
    }
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    String res = await _authMethods.signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
      _errorMessage = res;
    });

    if (res == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color chatgptGrey = Color(0xFF444654);
    const Color chatgptLightGrey = Color(0xFF5C5F6D);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Create a New Account', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24, bottom: 20, top: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: 80,
                  ),
                  SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (widget, animation) => FadeTransition(
                      opacity: animation,
                      child: widget,
                    ),
                    child: Text(
                      _currentText,
                      key: ValueKey<String>(_currentText),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: chatgptGrey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: chatgptGrey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chatgptGrey,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 40),

                  // Login Button
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style:
                          TextStyle(color: Color.fromARGB(255, 236, 237, 243)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
