import 'package:flutter/material.dart';
import 'package:mini_project_admin/UsersPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'adminLogin.dart';
import 'HomePage.dart';
import 'Products/productPage.dart';

class AppDrawer extends StatelessWidget {
  final String? adminEmail;

  const AppDrawer({super.key, this.adminEmail});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Drawer(
      backgroundColor: cardColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_3_rounded, size: 40, color: Colors.indigo),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adminEmail ?? "Admin User",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _drawerTile(context, Icons.dashboard_rounded, "Dashboard", Colors.blue, false, () {
            Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }),
          _drawerTile(context, Icons.people_alt_rounded, "User Directory", Colors.orange, false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersPage()));
          }),
          _drawerTile(context, Icons.category_rounded, "Inventory", Colors.purple, false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductPage()));
          }),
          _drawerTile(context, Icons.settings_suggest_rounded, "Settings", Colors.teal, false, () {
            Navigator.pop(context);
            // Navigate to Settings
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
                      const SizedBox(width: 10),
                      const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Switch(
                    value: isDark,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text("Logout Session", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              SharedPreferences sp = await SharedPreferences.getInstance();
              await sp.remove('email');
              await sp.setBool('login', false);
              await sp.clear();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => adminLogin()),);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String title, Color color, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: ListTile(
          leading: Icon(icon, size: 22, color: isSelected ? color : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? color : null,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
