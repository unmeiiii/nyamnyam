import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _settingsItem({
    required IconData icon,
    required String title,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage your preferences",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _settingsItem(
              icon: Icons.person_outline,
              title: "Account Information",
            ),
            _settingsItem(icon: Icons.lock_outline, title: "Change Password"),
            _settingsItem(
              icon: Icons.restaurant_menu,
              title: "Food Preferences",
            ),
            _settingsItem(
              icon: Icons.notifications_none,
              title: "Notification Settings",
            ),
            _settingsItem(
              icon: Icons.help_outline,
              title: "Help / Contact Admin",
            ),
            _settingsItem(icon: Icons.info_outline, title: "About App"),

            const SizedBox(height: 16),

            _settingsItem(
              icon: Icons.logout,
              title: "Logout",
              textColor: Colors.red,
            ),
            _settingsItem(
              icon: Icons.delete_outline,
              title: "Delete Account",
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
