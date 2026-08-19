import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppDrawer.dart';
import 'AppBottomNavBar.dart';

class Add_User extends StatefulWidget {
  const Add_User({super.key});

  @override
  State<Add_User> createState() => _Add_UserState();
}

class _Add_UserState extends State<Add_User> {
  final userNameController = TextEditingController();
  final userSurnameController = TextEditingController();
  final userGenderController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPhoneController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userConfirmPasswordController = TextEditingController();
  
  File? _userImage;
  File? _adharImage;
  final picker = ImagePicker();
  bool isLoading = false;
  String? adminEmail;
  final _formKey = GlobalKey<FormState>();

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

  Future _pickImage(bool isUserPhoto) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        if (isUserPhoto) {
          _userImage = File(pickedFile.path);
        } else {
          _adharImage = File(pickedFile.path);
        }
      });
    }
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
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        title: const Text("Register User", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dual Image Pickers
                    Row(
                      children: [
                        Expanded(
                          child: _buildImagePicker(
                            context, 
                            _userImage, 
                            "User Photo", 
                            Icons.person_add_rounded, 
                            () => _pickImage(true), 
                            isDark, 
                            primaryColor
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildImagePicker(
                            context, 
                            _adharImage, 
                            "Aadhaar Card", 
                            Icons.badge_rounded, 
                            () => _pickImage(false), 
                            isDark, 
                            primaryColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(userNameController, "First Name", Icons.person_outline_rounded, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(userSurnameController, "Last Name", Icons.badge_outlined, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(userGenderController, "Gender", Icons.wc_rounded, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(userEmailController, "Email Address", Icons.email_outlined, isDark, type: TextInputType.emailAddress),
                    const SizedBox(height: 18),
                    _buildInputField(userPhoneController, "Phone Number", Icons.phone_android_rounded, isDark, type: TextInputType.phone),
                    const SizedBox(height: 18),
                    _buildInputField(userPasswordController, "Password", Icons.lock_outline_rounded, isDark, isPassword: true),
                    const SizedBox(height: 18),
                    _buildInputField(userConfirmPasswordController, "Confirm Password", Icons.lock_reset_rounded, isDark, isPassword: true),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, File? image, String label, IconData icon, VoidCallback onTap, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: image == null ? primaryColor.withOpacity(0.2) : Colors.transparent, width: 2),
            ),
            child: image == null
                ? Icon(icon, size: 35, color: primaryColor)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType? type, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey, size: 22),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      validator: (value) => value!.isEmpty ? "Required field" : null,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userImage == null || _adharImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select both User and Aadhaar photos")));
      return;
    }
    if (userPasswordController.text != userConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);
    try {
      var url = Uri.parse("https://prakrutitech.xyz/MiniProject/insert_user.php");
      var request = http.MultipartRequest('POST', url)
        ..fields['name'] = userNameController.text.trim()
        ..fields['surname'] = userSurnameController.text.trim()
        ..fields['gender'] = userGenderController.text.trim()
        ..fields['email'] = userEmailController.text.trim()
        ..fields['phone'] = userPhoneController.text.trim()
        ..fields['password'] = userPasswordController.text.trim()
        ..files.add(await http.MultipartFile.fromPath('user_photo', _userImage!.path))
        ..files.add(await http.MultipartFile.fromPath('user_adharcard', _adharImage!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      String result = responseData.trim();

      if (response.statusCode == 200) {
        if (result == "0") {
          throw Exception("Missing details (API returned 0)");
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User registered successfully!")));
            Navigator.pop(context, true);
          }
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
