import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import '../AppBottomNavBar.dart';
import 'PModel.dart';

class ViewAllProducts extends StatefulWidget {
  const ViewAllProducts({super.key});

  @override
  State<ViewAllProducts> createState() => _ViewAllProductsState();
}

class _ViewAllProductsState extends State<ViewAllProducts> {
  String? adminEmail;
  late Future dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = getdata();
    _loadAdminData();
  }

  _loadAdminData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");
    });
  }

  getdata() async {
    try {
      var url = "https://prakrutitech.xyz/MiniProject/product_view&insert.php";
      var resp = await http.get(Uri.parse(url));
      return jsonDecode(resp.body);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA),
      extendBody: true,
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: const Text("Product Showcase", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return PModel(list: snapshot.data, onRefresh: () async {
              setState(() { dataFuture = getdata(); });
            }, isReadOnly: true);
          }
          return const Center(child: Text("No products available"));
        },
      ),
    );
  }
}
