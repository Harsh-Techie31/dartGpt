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
      // Navigate to the next screen (e.g., Chat screen)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up'),
                  ),
            SizedBox(height: 20),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 20),
            // TextButton for navigation to Login page
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(),
                  
                  ),
                  (route) => false, // Navigate to Login Page
                );
              },
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
