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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1219) : Colors.white,
        ),
        child: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -100,
              right: -50,
              child: _circularShape(250, primaryColor.withOpacity(0.1)),
            ),
            Positioned(
              bottom: -50,
              left: -80,
              child: _circularShape(300, Colors.indigo.withOpacity(0.05)),
            ),
            
            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / Header Section
                      Hero(
                        tag: 'admin_icon',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 70,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Administrator",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.indigo.shade900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "Control Center Access",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 45),
                      
                      // Login Form Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C212D) : Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("Email Address"),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: emailController,
                                hint: "admin@example.com",
                                icon: Icons.alternate_email_rounded,
                                isDark: isDark,
                                primaryColor: primaryColor,
                              ),
                              const SizedBox(height: 25),
                              _label("Access Token / Password"),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: passwordController,
                                hint: "••••••••",
                                icon: Icons.lock_open_rounded,
                                isDark: isDark,
                                primaryColor: primaryColor,
                                isPassword: true,
                              ),
                              const SizedBox(height: 40),
                              
                              // Login Button
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
                                    elevation: 10,
                                    shadowColor: primaryColor.withOpacity(0.5),
                                  ),
                                  child: _isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                    : const Text(
                                        "AUTHENTICATE",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "System Recovery Support",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularShape(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7), size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      validator: (value) => value!.isEmpty ? "Input required" : null,
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
              content: Text("Access Denied: Invalid Admin Credentials"), 
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
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
              content: Text("System Conflict: $responseBody"), 
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            )
          );
        }
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection Integrity Failure"), 
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
