import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'package:http/http.dart' as http;

class adminLogin extends StatefulWidget {
  const adminLogin({super.key});

  @override
  State<adminLogin> createState() => _adminLoginState();
}

class _adminLoginState extends State<adminLogin> {
  late SharedPreferences sp;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    sp = await SharedPreferences.getInstance();
    bool isLoggedIn = sp.getBool("login") ?? false;
    if (isLoggedIn) {
      if (mounted) {
        // Use post-frame callback to ensure context is ready for navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.8),
              primaryColor,
              primaryColor.withBlue(200),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    "Sign in to continue as Admin",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email Address",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: emailController,
                            decoration: _inputDecoration(
                              hint: "admin@example.com",
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) => value!.isEmpty ? "Enter your email" : null,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "Password",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: _inputDecoration(
                              hint: "••••••••",
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                            ),
                            validator: (value) => value!.isEmpty ? "Enter your password" : null,
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  signin(emailController.text, passwordController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, bool isPassword = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1.5),
      ),
    );
  }

  void signin(String e, String p) async {
    setState(() => _isLoading = true);
    final trimmedEmail = e.trim();
    final trimmedPassword = p.trim();

    try {
      var resp = await http.post(
        Uri.parse("https://prakrutitech.xyz/MiniProject/admin_login.php"),
        body: {
          "email": trimmedEmail, 
          "password": trimmedPassword
        },
      ).timeout(const Duration(seconds: 10));
      
      String responseBody = resp.body.trim();

      if (responseBody == "0") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid credentials or you are not an Admin"), 
              backgroundColor: Colors.redAccent
            )
          );
        }
        return;
      }

      try {
        var data = json.decode(responseBody);
        if (data is Map && data['code'] == 200) {
          sp = await SharedPreferences.getInstance();
          await sp.setString("email", trimmedEmail);
          await sp.setBool("login", true);
          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const HomePage())
            );
          }
        } else {
          throw Exception("Invalid code");
        }
      } catch (jsonError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error: $responseBody"), 
              backgroundColor: Colors.redAccent
            )
          );
        }
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection failed: Check your internet"),
            backgroundColor: Colors.orangeAccent
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
