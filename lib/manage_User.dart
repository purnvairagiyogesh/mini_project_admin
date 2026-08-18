import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Add_user.dart';
import 'Model.dart';
import 'AppDrawer.dart';
import 'AppBottomNavBar.dart';

class manageUser extends StatefulWidget {
  const manageUser({super.key});

  @override
  State<manageUser> createState() => _manageUserState();
}

class _manageUserState extends State<manageUser> {
  late SharedPreferences sp;
  String? adminEmail;
  late Future dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = getdata();
    _loadAdminData();
  }

  _loadAdminData() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");
    });
  }

  Future<void> _refresh() async {
    setState(() {
      dataFuture = getdata();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final scaffoldColor = isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: scaffoldColor,
      extendBody: true,
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        title: const Text("Manage Users", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Connection Issue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  )
                ],
              ),
            );
          }
          if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
            return Model(list: snapshot.data, onRefresh: _refresh);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 100, color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 20),
                const Text("No Users Found", style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Tap '+' to add your first user", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Add_User()),
            ).then((value) {
              if (value == true) _refresh();
            });
          },
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(Icons.person_add_rounded),
        ),
      ),
    );
  }

  getdata() async {
    try {
      var url = "https://prakrutitech.xyz/MiniProject/view_user.php";
      var resp = await http.get(Uri.parse(url));
      return jsonDecode(resp.body);
    } catch (e) {
      return null;
    }
  }
}
