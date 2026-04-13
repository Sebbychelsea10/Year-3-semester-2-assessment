import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Accessing the settings provider so we can read and update values
    final settings = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Toggle for dark mode

            SwitchListTile(
              title: const Text("Dark Mode"),
              value: settings.darkMode,
              onChanged: (value) {
                // Updates the value in provider + saves it
                settings.setDarkMode(value);
              },
            ),

// Toggle for notifications
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                // Updates notification setting
                settings.setNotifications(value);
              },
            ),

          ],
          
        ),
      ),
    );
  }
}