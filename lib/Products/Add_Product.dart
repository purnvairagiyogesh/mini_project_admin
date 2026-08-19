import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import '../AppBottomNavBar.dart';

class Add_Product extends StatefulWidget {
  const Add_Product({super.key});

  @override
  State<Add_Product> createState() => _Add_ProductState();
}

class _Add_ProductState extends State<Add_Product> {
  final _pNameController = TextEditingController();
  final _pPriceController = TextEditingController();
  final _pDiscountController = TextEditingController();
  final _pFeaturesController = TextEditingController();
  final _pRatingController = TextEditingController();
  final _pQuantityController = TextEditingController();
  
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
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
        title: const Text("Publish Product", style: TextStyle(fontWeight: FontWeight.bold)),
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
                            color: _image == null ? primaryColor.withOpacity(0.2) : Colors.transparent,
                            width: 2,
                            style: BorderStyle.solid
                          ),
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 45, color: primaryColor),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Upload Product Image",
                                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                  ),
                                ],
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
                    _buildInputField(_pQuantityController, "Stock Quantity", Icons.inventory_2_outlined, isDark, type: TextInputType.number),
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
                  onPressed: _isLoading ? null : _uploadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("LIST PRODUCT NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  void _uploadData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a product image")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse("https://prakrutitech.xyz/MiniProject/insert_product.php");
      var request = http.MultipartRequest('POST', url)
        ..fields['product_name'] = _pNameController.text.trim()
        ..fields['product_price'] = _pPriceController.text.trim()
        ..fields['final_discounted_price'] = _pDiscountController.text.trim()
        ..fields['ratings'] = _pRatingController.text.trim()
        ..fields['quantity'] = _pQuantityController.text.trim()
        ..fields['features'] = _pFeaturesController.text.trim()
        ..files.add(await http.MultipartFile.fromPath('product_image', _image!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      String result = responseData.trim();

      if (response.statusCode == 200) {
        if (result == "0") {
          throw Exception("Missing product details (API returned 0)");
        } else {
          // Success: PHP doesn't echo anything on success, so no '0' means success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product listed successfully!")));
            Navigator.pop(context, true);
          }
        }
      } else {
        print(_pNameController);
        print(_pPriceController);
        print(_pDiscountController);
        print(_pRatingController);
        print(_pFeaturesController);
        print(_image);
        print(response.statusCode);
        throw Exception('Failed to upload. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
