import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Update_User.dart';

class Model extends StatelessWidget {
  final List<dynamic> list;
  final RefreshCallback onRefresh;

  const Model({super.key, required this.list, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        itemCount: list.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToEdit(context, item),
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // User Photo (Amazon-style circle or rounded square)
                      Container(
                        height: 65,
                        width: 65,
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
                          child: Image.network(
                            item["user_image"] ?? "",
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.indigo.shade100,
                              child: const Icon(Icons.person_rounded, color: Colors.indigo, size: 35),
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
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item["gender"] ?? "N/A",
                                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item["phone"] ?? "",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => _navigateToEdit(context, item),
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            style: IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.1), foregroundColor: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          IconButton.filledTonal(
                            onPressed: () => _showDeleteDialog(context, item["id"]),
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.redAccent),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
        builder: (context) => Update_User(
          id: item["id"],
          name: item["name"],
          surname: item["surname"],
          gender: item["gender"] ?? "",
          email: item["email"] ?? "",
          phone: item["phone"] ?? "",
          password: item["password"] ?? "",
          userImage: item["user_image"] ?? "",
          adharImage: item["adhar_image"] ?? "",
        ),
      ),
    ).then((value) {
      if (value == true) onRefresh();
    });
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Delete User?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this user from the registry?"),
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
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed")));
      }
    }
  }
}
