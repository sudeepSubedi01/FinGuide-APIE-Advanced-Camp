import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        categories = List<Map<String, dynamic>>.from(cats);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading categories: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008080),
      appBar: _coolAppBar(),
      body: Column(
        children: [
          _addCategoryButton(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                  ? const Center(child: Text("No categories yet"))
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 12),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.black12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return _categoryTile(cat);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _coolAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Manage Categories",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _addCategoryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ElevatedButton.icon(
        onPressed: _openAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Category"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF008080),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  Widget _categoryTile(Map<String, dynamic> category) {
    return ListTile(
      title: Text(capitalize(category['name'])),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteCategory(category['id']),
      ),
    );
  }

  Future<void> _openAddCategoryDialog() async {
    String? name;

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: TextField(
            decoration: const InputDecoration(labelText: "Category Name"),
            onChanged: (val) => name = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name != null && name!.trim().isNotEmpty) {
                  _addCategory(name!.trim());
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (added == true) _loadCategories();
  }

  Future<void> _addCategory(String name) async {
    try {
      await ApiService.createCategory(name: name);
      _loadCategories();
    } catch (e) {
      debugPrint("Failed to add category: $e");
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      await ApiService.deleteCategory(id);
      _loadCategories();
    } catch (e) {
      debugPrint("Failed to delete category: $e");
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
