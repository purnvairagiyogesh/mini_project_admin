import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppDrawer.dart';
import 'AppBottomNavBar.dart';
import 'Add_user.dart';
import 'manage_User.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String? adminEmail;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  _loadAdminData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final scaffoldColor = isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldColor,
      extendBody: true,
      appBar: AppBar(
        title: const Text("User Management", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Manage Users",
                    subtitle: "Edit / Delete",
                    icon: Icons.manage_accounts_rounded,
                    color: Colors.blueAccent,
                    cardColor: cardColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const manageUser()));
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: "Add User",
                    subtitle: "Create New",
                    icon: Icons.person_add_alt_1_rounded,
                    color: Colors.greenAccent.shade700,
                    cardColor: cardColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Add_User()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Database Operations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildWideCard(
                context,
                title: "View All Users",
                subtitle: "Full database registry access",
                icon: Icons.supervised_user_circle_rounded,
                color: Colors.purpleAccent,
                cardColor: cardColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const manageUser()));
                },
              ),
              const SizedBox(height: 25),
              _buildInfoBanner(isDark, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required Color cardColor,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required Color cardColor,
      required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 35, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.black87, Colors.black] : [primaryColor.withOpacity(0.8), primaryColor],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.white70),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Regularly audit user roles to maintain security standards.",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
