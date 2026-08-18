import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import '../AppBottomNavBar.dart';
import 'Add_Product.dart';
import 'PModel.dart';

class manageProduct extends StatefulWidget {
  const manageProduct({super.key});

  @override
  State<manageProduct> createState() => _manageProductState();
}

class _manageProductState extends State<manageProduct> {
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

  Future<void> _refresh() async {
    setState(() {
      dataFuture = getdata();
    });
  }

  getdata() async {
    try {
      // Using the user-provided API
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
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA),
      extendBody: true,
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: const Text("Control Center", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return PModel(list: snapshot.data, onRefresh: _refresh, isReadOnly: false);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text("Empty Inventory", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Add_Product())).then((v) => _refresh());
          },
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
