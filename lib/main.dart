import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/setting_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingProvider(),
      child: const MyApp(),
    ),
  );
}

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // theme based on settings
      theme: settings.darkMode
          ? ThemeData.dark()
          : ThemeData.light(),

      home: username == null
          ? const LoginScreen()
          : HomeScreen(username: username!),
    );
    
  }
}