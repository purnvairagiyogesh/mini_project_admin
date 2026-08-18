import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import '../AppBottomNavBar.dart';

class Update_Product extends StatefulWidget {
  final String id, pname, pprice, pimage, pfinal_price, pfeature, prating;
  const Update_Product({
    super.key,
    required this.id,
    required this.pname,
    required this.pprice,
    required this.pimage,
    required this.pfinal_price,
    required this.pfeature,
    required this.prating,
  });

  @override
  State<Update_Product> createState() => _Update_ProductState();
}

class _Update_ProductState extends State<Update_Product> {
  late TextEditingController _pNameController, _pPriceController, _pDiscountController, _pFeaturesController, _pRatingController;
  
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
  String? adminEmail;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pNameController = TextEditingController(text: widget.pname);
    _pPriceController = TextEditingController(text: widget.pprice);
    _pDiscountController = TextEditingController(text: widget.pfinal_price);
    _pFeaturesController = TextEditingController(text: widget.pfeature);
    _pRatingController = TextEditingController(text: widget.prating);
    _loadAdminData();
  }

  _loadAdminData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");
    });
  }

  Future _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: const Text("Edit Product", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    // Image Picker Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 2,
                            style: BorderStyle.solid
                          ),
                        ),
                        child: _image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Image.network(
                                  "https://prakrutitech.xyz/MiniProject/${widget.pimage}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_rounded, size: 45, color: primaryColor),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Change Product Image",
                                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(_pNameController, "Product Name", Icons.shopping_bag_outlined, isDark),
                    const SizedBox(height: 18),
                    _buildInputField(_pPriceController, "Market Price (MRP)", Icons.payments_outlined, isDark, type: TextInputType.number),
                    const SizedBox(height: 18),
                    _buildInputField(_pDiscountController, "Final Deal Price", Icons.savings_outlined, isDark, type: TextInputType.number),
                    const SizedBox(height: 18),
                    _buildInputField(_pRatingController, "Initial Rating (1-5)", Icons.star_outline_rounded, isDark, type: TextInputType.number),
                    const SizedBox(height: 18),
                    _buildInputField(_pFeaturesController, "Description & Features", Icons.description_outlined, isDark, lines: 4),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("UPDATE PRODUCT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType? type, int lines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: lines,
      style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: lines > 1 ? 75 : 0),
          child: Icon(icon, color: Colors.grey, size: 22),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
      validator: (value) => value!.isEmpty ? "This field is required" : null,
    );
  }

  void _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse("https://prakrutitech.xyz/MiniProject/product_update.php");
      var request = http.MultipartRequest('POST', url)
        ..fields['id'] = widget.id
        ..fields['product_name'] = _pNameController.text.trim()
        ..fields['product_price'] = _pPriceController.text.trim()
        ..fields['final_discounted_price'] = _pDiscountController.text.trim()
        ..fields['ratings'] = _pRatingController.text.trim()
        ..fields['features'] = _pFeaturesController.text.trim();

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('product_image', _image!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product updated successfully!")));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
