import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            SwitchListTile(
              title: const Text("Dark Mode"),
              value: settings.darkMode,
              onChanged: (value) {
                settings.setDarkMode(value);
              },
            ),


            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                settings.setNotifications(value);
              },
            ),

          ],
          
        ),
      ),
    );
  }
}