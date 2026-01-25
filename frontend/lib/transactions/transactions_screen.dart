import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import 'widgets/transaction_tile.dart';
import 'add_transaction_form.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  bool isLoading = true;
  List<TransactionModel> transactions = [];
  List<TransactionModel> filteredTransactions = [];

  String filter = "All";
  DateTime? customStartDate;
  DateTime? customEndDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final txs = await ApiService.getTransactions(1);
      // txs.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        transactions = txs;
        filteredTransactions = List.from(txs);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008080),
      appBar: _coolAppBar(),
      body: Column(
        children: [
          _actionButtons(),
          _filterToggle(),
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
                  : transactions.isEmpty
                  ? const Center(child: Text("No transactions yet"))
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 12),
                      // itemCount: transactions.length,
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.black12),
                      itemBuilder: (context, index) {
                        return TransactionTile(
                          // transaction: transactions[index],
                          transaction: filteredTransactions[index],
                          textColor: Colors.black87,
                        );
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
        "Transactions",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openAddTransaction(false),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Income"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openAddTransaction(true),
              icon: const Icon(Icons.remove, size: 18),
              label: const Text("Add Expense"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterChip("ALL"),
          const SizedBox(width: 8),
          _filterChip("THIS MONTH"),
          const SizedBox(width: 8),
          _filterChip("CUSTOM"),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) async {
        if (label == "CUSTOM") {
          await _pickCustomDateRange();
        }
        setState(() {
          filter = label;
        });
        _applyFilter();
      },
      selectedColor: Colors.green,
      backgroundColor: Colors.white24,
      labelStyle: TextStyle(
        color: isSelected
            ? const Color(0xFF008080)
            : const Color.fromARGB(255, 199, 183, 183),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _openAddTransaction(bool isExpense) async {
    final added = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionForm(isExpense: isExpense, userId: 1),
      ),
    );

    if (added == true) {
      _loadTransactions();
    }
  }

  void _applyFilter() {
    List<TransactionModel> result = [...transactions];

    if (filter == "THIS MONTH") {
      final now = DateTime.now();
      result = result.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }).toList();
    }

    if (filter == "CUSTOM" &&
        customStartDate != null &&
        customEndDate != null) {
      result = result.where((tx) {
        return tx.date.isAfter(
              customStartDate!.subtract(const Duration(days: 1)),
            ) &&
            tx.date.isBefore(customEndDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      filteredTransactions = result;
    });
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
      });
    }
  }
}
