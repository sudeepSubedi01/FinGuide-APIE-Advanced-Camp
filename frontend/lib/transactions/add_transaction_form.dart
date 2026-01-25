import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddTransactionForm extends StatefulWidget {
  final bool isExpense;
  final int userId;

  const AddTransactionForm({
    super.key,
    required this.isExpense,
    required this.userId,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  double? amount;
  String? description;
  DateTime selectedDate = DateTime.now();
  int? categoryId;

  List<Map<String, dynamic>> categories = [];
  bool loadingCategories = false;

  @override
  void initState() {
    super.initState();
    if (widget.isExpense) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => loadingCategories = true);
      final cats = await ApiService.getCategories();
      setState(() {
        categories = List<Map<String, dynamic>>.from(cats);
        if (categories.isNotEmpty && categoryId == null) {
          categoryId = categories[0]['category_id'];
        }

        loadingCategories = false;
      });
    } catch (e) {
      debugPrint("Failed to load categories: $e");
      setState(() => loadingCategories = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await ApiService.createTransaction(
        amount: amount!,
        categoryId: widget.isExpense ? categoryId : null,
        transactionType: widget.isExpense ? "expense" : "income",
        transactionDate: selectedDate,
        description: description ?? "",
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Failed to create transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to add transaction"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isExpense
        ? const Color(0xFFEF4444)
        : const Color(0xFF22C55E);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 12,
          left: 24,
          right: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.isExpense
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.isExpense ? "Add Expense" : "Add Income",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildTextField(
                label: "Amount",
                icon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter an amount" : null,
                onSaved: (val) => amount = double.tryParse(val ?? "0"),
              ),
              const SizedBox(height: 16),
              if (widget.isExpense) ...[
                _buildDropdown(),
                const SizedBox(height: 16),
              ],
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Description",
                icon: Icons.notes_rounded,
                onSaved: (val) => description = val,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isExpense ? "Add Expense" : "Add Income",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: categoryId,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        labelText: "Category",
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF0D9488)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
        ),
      ),
      items: categories.map((c) {
        return DropdownMenuItem<int>(
          value: c['category_id'] as int?,
          child: Text(c['name']?.toString() ?? "Unnamed"),
        );
      }).toList(),
      onChanged: (int? val) {
        setState(() {
          categoryId = val;
        });
      },
      validator: (val) {
        if (widget.isExpense && val == null) {
          return "Please select a category";
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0D9488),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1F2937),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF0D9488)),
            const SizedBox(width: 12),
            Text(
              DateFormat("MMMM dd, yyyy").format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
