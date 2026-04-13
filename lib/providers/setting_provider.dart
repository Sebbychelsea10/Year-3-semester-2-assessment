import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider with ChangeNotifier {
  bool _darkMode = false;
  bool _notificationsEnabled = true;


  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  // Constructor (loads saved settings)
  SettingProvider() {
    _loadSettings();
  }

  // this function loads the saved settings from shared preferences when the provider is initialized
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool("darkMode") ?? false;
    _notificationsEnabled = prefs.getBool("notifications") ?? true;

    notifyListeners();
  }


  // this toggles the dark mode setting and saves it to shared preferences 
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);

    notifyListeners();
  }


  
  // this function updates the notification setting and saves it to shared preferences so it persists across app restarts
  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications", value);

    notifyListeners();

  }

}