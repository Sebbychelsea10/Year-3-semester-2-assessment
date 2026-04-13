import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/setting_provider.dart';

// Main entry point of the app. It checks if a user is already logged in and shows either the login screen or home screen accordingly. It also sets up the settings provider for managing app settings like dark mode and notifications.

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingProvider(),
      child: const MyApp(),
    ),
  );
}

// This widget is the root of the application. It checks if a user is logged in and shows the appropriate screen. It also listens to changes in settings to update the theme dynamically.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? username;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }


// This function checks if there is a currently logged in user by looking for a saved username in shared preferences. It updates the state to show the correct screen based on whether a user is found or not.
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("current_user");

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingProvider>(context);

    if (loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    // The MaterialApp uses the dark mode setting from the provider to switch themes dynamically. It also decides which screen to show based on whether a user is logged in or not.

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
          settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: username == null
          ? const LoginScreen()
          : HomeScreen(username: username!),
    );
  }
}