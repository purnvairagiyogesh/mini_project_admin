import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Update_User.dart';

class Model extends StatefulWidget {
  final List<dynamic> list;
  final RefreshCallback onRefresh;
  final bool isReadOnly;

  const Model({
    super.key,
    required this.list,
    required this.onRefresh,
    this.isReadOnly = false,
  });

  @override
  State<Model> createState() => _ModelState();
}

class _ModelState extends State<Model> {
  final Set<int> _expandedItems = {};

  // Helper to ensure URL is full
  String _formatUrl(String? url) {
    if (url == null || url.isEmpty || url == "null") return "";
    if (url.startsWith("http")) return url;
    // If it's a relative path, we prepend the base URL.
    // Based on your previous API, it might be in an 'images' or 'API/images' folder.
    if (url.startsWith("/")) {
      return "https://prakrutitech.xyz$url";
    }
    return "https://prakrutitech.xyz/MiniProject/$url";
  }

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
          
          final userImageUrl = _formatUrl(item["user_photo"]);
          final adharImageUrl = _formatUrl(item["user_adharcard"]);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                          children: [
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, userImageUrl),
                              child: Hero(
                                tag: "user_photo_$index",
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.indigo.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: userImageUrl.isNotEmpty 
                                      ? Image.network(
                                          userImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: Colors.indigo.shade100,
                                            child: const Icon(Icons.person_rounded, color: Colors.indigo, size: 35),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.indigo.shade100,
                                          child: const Icon(Icons.person_rounded, color: Colors.indigo, size: 35),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item["name"]} ${item["surname"]}",
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item["email"] ?? "No Email",
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: primaryColor,
                              size: 30,
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
                          _buildDetailRow(Icons.phone_android_rounded, "Phone", item["phone"] ?? "N/A"),
                          const SizedBox(height: 10),
                          _buildDetailRow(Icons.wc_rounded, "Gender", item["gender"] ?? "N/A"),
                          const SizedBox(height: 20),
                          
                          const Text(
                            "Aadhaar Card Photo",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          
                          GestureDetector(
                            onTap: () => _showFullScreenImage(context, adharImageUrl),
                            child: Hero(
                              tag: "adhar_photo_$index",
                              child: Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: adharImageUrl.isNotEmpty
                                    ? Image.network(
                                        adharImageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.badge_outlined, size: 50, color: Colors.grey),
                                              SizedBox(height: 10),
                                              Text("Aadhaar Image Not Found", style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.badge_outlined, size: 50, color: Colors.grey),
                                            SizedBox(height: 10),
                                            Text("No Aadhaar Uploaded", style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),

                          if (!widget.isReadOnly) ...[
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _navigateToEdit(context, item),
                                    icon: const Icon(Icons.edit_rounded, size: 18),
                                    label: const Text("Update"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(0.1),
                                      foregroundColor: Colors.blue,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showDeleteDialog(context, item["id"]),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    label: const Text("Delete"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      foregroundColor: Colors.redAccent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
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
            title: const Text("Image View", style: TextStyle(color: Colors.white)),
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
        builder: (context) => Update_User(
          id: item["id"],
          name: item["name"],
          surname: item["surname"],
          gender: item["gender"] ?? "",
          email: item["email"] ?? "",
          phone: item["phone"] ?? "",
          password: item["password"] ?? "",
          userImage: item["user_photo"] ?? "",
          adharImage: item["user_adharcard"] ?? "",
        ),
      ),
    ).then((value) {
      if (value == true) widget.onRefresh();
    });
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Delete User?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deletedata(context, id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Confirm Delete"),
          ),
        ],
      ),
    );
  }

  void deletedata(BuildContext context, id) async {
    try {
      await http.post(
        Uri.parse("https://prakrutitech.xyz/MiniProject/delete_user.php"),
        body: {"id": id},
      );
      widget.onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed")));
      }
    }
  }
}
