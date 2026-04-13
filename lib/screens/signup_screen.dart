import 'package:flutter/material.dart';
import '../services/database_helper.dart';

// Screen for creating a new user account

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupScreen> {

  // Controllers to get input from text fields

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

// Handles the signup process
  Future<void> signup() async {

// Get user input and remove extra spaces
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Basic validation to make sure fields aren't empty

    if (username.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter username and password")),
      );

      return;
    }

    // Insert new user into the database

    await DatabaseHelper().insertUser(username, password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully")),
    );
// Go back to login screen after signup
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Create Account")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [
            // Username input

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            const SizedBox(height: 15),
             // Password input (hidden for security)

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 25),


            // Button to trigger signup

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: signup,
                child: const Text("Create Account"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}