import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
   // Controllers used to get what the user types into the text fields

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // This function runs when the user presses the login button

  Future<void> login() async {
// Get input values and remove any extra spaces
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Check if the user exists in the database

    bool validUser = await DatabaseHelper().validateUser(username, password);

    if (validUser) {

      // If login is correct, move to the home screen

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(username: username),
        ),
      );

    } else {

       // If login fails, show an error message

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid username or password"),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // Username input field

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            const SizedBox(height: 15),
             // Password input field (hidden text)

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 25),

            // Login button

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 10),

             // Navigate to signup page if user doesn't have an account

            TextButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );

              },
              child: const Text("Create Account"),
            ),

          ],
        ),
      ),
    );
  }
}