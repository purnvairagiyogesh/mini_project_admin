import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Update_Product.dart';
import 'Update_Price.dart';

class PModel extends StatefulWidget {
  final List<dynamic> list;
  final RefreshCallback onRefresh;
  final bool isReadOnly;

  const PModel({
    super.key,
    required this.list,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  State<PModel> createState() => _PModelState();
}

class _PModelState extends State<PModel> {
  final Set<int> _expandedItems = {};
  final Set<int> _showPriceItems = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.indigoAccent : Colors.indigo.shade700;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        itemCount: widget.list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.list[index];
          final isExpanded = _expandedItems.contains(index);
          final isPriceVisible = _showPriceItems.contains(index);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) _expandedItems.remove(index);
                          else _expandedItems.add(index);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section with Full View
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, item['product_image'] ?? ""),
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    item['product_image'] ?? "",
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["product_name"] ?? "Unknown",
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
                                      const SizedBox(width: 4),
                                      Text("${item['ratings'] ?? '0.0'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Qty: ${item['quantity'] ?? item['product_quantity'] ?? '0'}",
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Price: ₹${item['product_price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Expand Icon
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: primaryColor,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isExpanded) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NEW: Expandable Price Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isPriceVisible) _showPriceItems.remove(index);
                                else _showPriceItems.add(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer_rounded, size: 18, color: primaryColor),
                                  const SizedBox(width: 10),
                                  Text(
                                    isPriceVisible ? "Hide Discounted Price" : "View Final Discounted Price",
                                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    isPriceVisible ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if (isPriceVisible) ...[
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Final Deal Price:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(
                                    "₹${item['final_discount_price'] ?? item['final_discounted_price']}",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                          const Text("Key Features:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            item["features"] ?? "No details provided.",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.5),
                          ),
                          if (!widget.isReadOnly) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _navigateToEdit(context, item),
                                    icon: const Icon(Icons.edit_note_rounded),
                                    label: const Text("Edit"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(0.1),
                                      foregroundColor: Colors.blue,
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Update_Price(product: item)),
                                      ).then((_) => widget.onRefresh());
                                    },
                                    icon: const Icon(Icons.sell_rounded),
                                    label: const Text("Price"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.withOpacity(0.1),
                                      foregroundColor: Colors.green,
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () => _showDeleteDialog(context, item["product_id"]),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  style: IconButton.styleFrom(foregroundColor: Colors.redAccent),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Update_Product(
          id: item["product_id"].toString(),
          pname: item["product_name"],
          pprice: item["product_price"],
          pimage: item["product_image"] ?? "",
          pfinal_price: (item["final_discount_price"] ?? item["final_discounted_price"]).toString(),
          pfeature: item["features"] ?? "",
          prating: item["ratings"].toString(),
          pquantity: (item["quantity"] ?? item["product_quantity"] ?? '0').toString(),
        ),
      ),
    ).then((value) {
      if (value == true) widget.onRefresh();
    });
  }

  void _showDeleteDialog(BuildContext context, dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Delete this product permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deletedata(context, id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void deletedata(BuildContext context, dynamic id) async {
    try {
      await http.post(
        Uri.parse("https://prakrutitech.xyz/MiniProject/delete_product.php"),
        body: {"id": id.toString()},
      );
      widget.onRefresh();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed")));
    }
  }
}
