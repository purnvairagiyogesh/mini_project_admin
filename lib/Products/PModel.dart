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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        Container(
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "MRP: ₹${item['product_price']}",
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "Deal Price: ₹${item['final_discount_price'] ?? item['final_discounted_price']}",
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ]
                            ],
                          ),
                        ),
                        // Actions Column
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) _expandedItems.remove(index);
                                  else _expandedItems.add(index);
                                });
                              },
                              icon: Icon(
                                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: primaryColor,
                              ),
                            ),
                            if (!widget.isReadOnly) ...[
                              IconButton(
                                onPressed: () => _navigateToEdit(context, item),
                                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Update_Price(product: item)),
                                  ).then((_) => widget.onRefresh());
                                },
                                icon: const Icon(Icons.sell_rounded, color: Colors.green),
                                tooltip: "Update Discount",
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Key Features:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            item["features"] ?? "No details provided.",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, height: 1.5),
                          ),
                          if (!widget.isReadOnly) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showDeleteDialog(context, item["product_id"]),
                                icon: const Icon(Icons.delete_sweep_rounded),
                                label: const Text("DELETE PRODUCT"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  foregroundColor: Colors.red,
                                  elevation: 0,
                                ),
                              ),
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
