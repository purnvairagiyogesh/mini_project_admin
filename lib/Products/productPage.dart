import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import 'package:mini_project_admin/AppBottomNavBar.dart';
import 'Add_Product.dart';
import 'managePoduct.dart';
import 'ViewAllProducts.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
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
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA),
      extendBody: true,
      appBar: AppBar(
        title: const Text("Stock Management", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
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
                    title: "Manage Stock",
                    subtitle: "Edit, Delete & Prices",
                    icon: Icons.inventory_2_rounded,
                    color: Colors.orangeAccent,
                    cardColor: cardColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const manageProduct()));
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: "New Product",
                    subtitle: "Add Entry",
                    icon: Icons.add_photo_alternate_rounded,
                    color: Colors.tealAccent.shade700,
                    cardColor: cardColor,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Add_Product()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Inventory Registry",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildWideCard(
                context,
                title: "View All Products",
                subtitle: "Amazon-style read-only inventory list",
                icon: Icons.grid_view_rounded,
                color: Colors.deepPurpleAccent,
                cardColor: cardColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAllProducts()));
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
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
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
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 15),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
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
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Icon(icon, size: 35, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
          colors: isDark ? [const Color(0xFF311B92), Colors.black] : [primaryColor.withOpacity(0.8), primaryColor],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_rounded, color: Colors.amber),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Regularly update discounted prices to boost seasonal sales.",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
