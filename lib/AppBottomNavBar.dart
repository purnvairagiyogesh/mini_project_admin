import 'package:flutter/material.dart';
import 'package:mini_project_admin/UsersPage.dart';
import 'HomePage.dart';
import 'Products/productPage.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.dashboard_rounded, "Dash", 0, primaryColor),
          _navItem(context, Icons.people_alt_rounded, "Users", 1, Colors.orange),
          _navItem(context, Icons.category_rounded, "Inv", 2, Colors.purple),
          _navItem(context, Icons.settings_suggest_rounded, "Set", 3, Colors.teal),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index, Color color) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (currentIndex == index) return;
        
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const HomePage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const UsersPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const ProductPage(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade500, size: 24),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
