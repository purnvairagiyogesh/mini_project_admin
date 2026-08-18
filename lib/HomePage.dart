import 'package:flutter/material.dart';
import 'package:mini_project_admin/Products/productPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'adminLogin.dart';
import 'UsersPage.dart';
import 'AppDrawer.dart';
import 'AppBottomNavBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sp;
  String? adminEmail;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  _loadAdminData() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");

    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic Colors for attractive look in both modes
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final scaffoldColor = isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldColor,
      extendBody: true,
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(primaryColor, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 120), // Bottom padding for Nav Bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Management",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: "Users",
                          subtitle: "Manage Data",
                          icon: Icons.group_add_rounded,
                          color: Colors.blueAccent,
                          cardColor: cardColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UsersPage()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionCard(
                          title: "Products",
                          subtitle: "Inventory",
                          icon: Icons.auto_awesome_motion_rounded,
                          color: Colors.orangeAccent,
                          cardColor: cardColor,
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProductPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildStatsSection(cardColor),
                  const SizedBox(height: 35),
                  const Text(
                    "System Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildBannerCard(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Color primaryColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          adminEmail ?? "DASHBOARD",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                    : [primaryColor, primaryColor.withBlue(255)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative shapes
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              left: -20,
              bottom: 50,
              child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.03)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "DASHBOARD",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.admin_panel_settings, color: Colors.white.withOpacity(0.2), size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: "Sales", value: "85%", icon: Icons.trending_up, color: Colors.green),
          _StatItem(label: "Orders", value: "1.2k", icon: Icons.shopping_bag_outlined, color: Colors.blue),
          _StatItem(label: "Issues", value: "02", icon: Icons.bug_report_outlined, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildBannerCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.indigo.shade900, Colors.black] : [Colors.indigo.shade800, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_update_good, color: Colors.amber, size: 30),
          SizedBox(height: 15),
          Text("System Performance: Optimal", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
            "All systems are running smoothly. Database optimized 2 hours ago.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(Color cardColor, bool isDark) {
    return Container();
  }

  Widget _activityTile(String title, String time, IconData icon, Color color) {
    return Container();
  }

  Widget _divider(bool isDark) => Container();
  
  Widget _buildSearchBar(bool isDark, Color cardColor) {
    return Container();
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
