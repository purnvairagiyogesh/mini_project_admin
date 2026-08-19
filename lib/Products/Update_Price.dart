import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../AppDrawer.dart';
import '../AppBottomNavBar.dart';

class Update_Price extends StatefulWidget {
  final Map<String, dynamic> product;
  const Update_Price({super.key, required this.product});

  @override
  State<Update_Price> createState() => _Update_PriceState();
}

class _Update_PriceState extends State<Update_Price> {
  late TextEditingController _priceController;
  bool _isLoading = false;
  String? adminEmail;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: (widget.product['final_discount_price'] ?? widget.product['final_discounted_price'] ?? '').toString()
    );
    _loadAdminData();
  }

  _loadAdminData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      adminEmail = sp.getString("email");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;
    final cardColor = isDark ? const Color(0xFF1C212D) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF5F7FA),
      extendBody: true,
      drawer: AppDrawer(adminEmail: adminEmail),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        title: const Text("Edit Discount", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
        child: Column(
          children: [
            // Read-Only Product Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.product['product_image'] ?? "",
                      height: 80, width: 80, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => const Icon(Icons.image, size: 40),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product['product_name'] ?? "Product", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text("Current MRP: ₹${widget.product['product_price']}", style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        Row(
                          children: [
                            Text("Rating: ${widget.product['ratings']}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 15),
                            Text("Qty: ${widget.product['product_quantity'] ?? '0'}", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Features display (Read only as per request)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product Features", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.product['features'] ?? "No features listed.", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Editable Input Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("New Discounted Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SAVE NEW PRICE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePrice() async {
    setState(() => _isLoading = true);
    try {
      // Using the specific API URL provided by user
      var resp = await http.post(
        Uri.parse("https://prakrutitech.xyz/MiniProject/product_view&insert.php"),
        body: {
          "product_id": (widget.product['product_id'] ?? widget.product['id']).toString(),
          "final_discount_price": _priceController.text.trim(),
        },
      );
      if (resp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Price successfully updated!")));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission failed")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
