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
      final cats = await ApiService.getCategories(userId: widget.userId);
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
        userId: widget.userId,
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
        const SnackBar(content: Text("Failed to add transaction")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isExpense ? "Add Expense" : "Add Income",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
              validator: (val) =>
                  val == null || val.isEmpty ? "Enter an amount" : null,
              onSaved: (val) => amount = double.tryParse(val ?? "0"),
            ),
            const SizedBox(height: 12),

            // Category (ONLY for Expense)
            if (widget.isExpense)
              DropdownButtonFormField<int>(
                value: categoryId,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['category_id'] as int?,
                    child: Text(
                      c['name']?.toString() ?? "Unnamed",
                    ), // 5. Display the name safely
                  );
                }).toList(),
                onChanged: (int? val) {
                  // 6. 'val' is now int?
                  setState(() {
                    categoryId = val; // 7. int? assigned to int? - No error!
                  });
                },
                validator: (val) {
                  // val here is an int?
                  if (widget.isExpense && val == null) {
                    return "Please select a category";
                  }
                  return null;
                },
              ),

            const SizedBox(height: 12),

            // Date
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Date"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat("yyyy-MM-dd").format(selectedDate)),
                    const Icon(Icons.calendar_today, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Description
            TextFormField(
              decoration: const InputDecoration(labelText: "Description"),
              onSaved: (val) => description = val,
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: _submit, child: const Text("Add")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
