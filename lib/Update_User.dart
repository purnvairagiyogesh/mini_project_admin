import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppDrawer.dart';
import 'AppBottomNavBar.dart';

class Update_User extends StatefulWidget {
  final String id, name, surname, gender, email, phone, password, userImage, adharImage;
  const Update_User({
    super.key,
    required this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.email,
    required this.phone,
    required this.password,
    required this.userImage,
    required this.adharImage,
  });

  @override
  State<Update_User> createState() => _Update_UserState();
}

class _Update_UserState extends State<Update_User> {
  late TextEditingController nameController, surnameController, genderController, emailController, phoneController, passController;
  
  File? _newUserImage;
  File? _newAdharImage;
  final picker = ImagePicker();
  bool isLoading = false;
  String? adminEmail;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    surnameController = TextEditingController(text: widget.surname);
    genderController = TextEditingController(text: widget.gender);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    passController = TextEditingController(text: widget.password);
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
          _newUserImage = File(pickedFile.path);
        } else {
          _newAdharImage = File(pickedFile.path);
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
        title: const Text("Update User", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      color: Colors.blueAccent.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dual Image Pickers for Updates
                    Row(
                      children: [
                        Expanded(
                          child: _buildUpdateImagePicker(
                            "User Photo", 
                            widget.userImage, 
                            _newUserImage, 
                            () => _pickImage(true), 
                            isDark, 
                            primaryColor
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildUpdateImagePicker(
                            "Aadhaar Card", 
                            widget.adharImage, 
                            _newAdharImage, 
                            () => _pickImage(false), 
                            isDark, 
                            primaryColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text("User ID: ${widget.id}", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 32),
                    _buildInputField(nameController, "First Name", Icons.person_outline_rounded, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(surnameController, "Last Name", Icons.badge_outlined, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(genderController, "Gender", Icons.wc_rounded, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(emailController, "Email Address", Icons.email_outlined, isDark, type: TextInputType.emailAddress),
                    const SizedBox(height: 18),
                    _buildInputField(phoneController, "Phone Number", Icons.phone_android_rounded, isDark, type: TextInputType.phone),
                    const SizedBox(height: 18),
                    _buildInputField(passController, "Password", Icons.lock_outline_rounded, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _update(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("UPDATE USER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateImagePicker(String label, String currentUrl, File? newFile, VoidCallback onTap, bool isDark, Color primaryColor) {
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
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: newFile != null 
                ? Image.file(newFile, fit: BoxFit.cover)
                : Image.network(
                    currentUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.person_rounded, color: Colors.grey),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType? type}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
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

  void _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      var url = Uri.parse("https://prakrutitech.xyz/MiniProject/update_user.php");
      var request = http.MultipartRequest('POST', url)
        ..fields['id'] = widget.id
        ..fields['name'] = nameController.text.trim()
        ..fields['surname'] = surnameController.text.trim()
        ..fields['gender'] = genderController.text.trim()
        ..fields['email'] = emailController.text.trim()
        ..fields['phone'] = phoneController.text.trim()
        ..fields['password'] = passController.text.trim();

      if (_newUserImage != null) {
        request.files.add(await http.MultipartFile.fromPath('user_photo', _newUserImage!.path));
      }
      if (_newAdharImage != null) {
        request.files.add(await http.MultipartFile.fromPath('user_adharcard', _newAdharImage!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User updated successfully")));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update failed")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
