import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../dashboard/widgets/transaction_tile.dart';
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

  String filter = "ALL";
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
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D9488),
              Color(0xFF115E59),
              Color(0xFF134E4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildActionButtons(),
              const SizedBox(height: 8),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(child: _buildTransactionsList()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Transactions",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildGlassButton(
            icon: Icons.add_rounded,
            label: "Income",
            color: const Color(0xFF22C55E),
            onTap: () => _openAddTransaction(false),
          )),
          const SizedBox(width: 14),
          Expanded(child: _buildGlassButton(
            icon: Icons.remove_rounded,
            label: "Expense",
            color: const Color(0xFFEF4444),
            onTap: () => _openAddTransaction(true),
          )),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip("ALL"),
          const SizedBox(width: 10),
          _buildFilterChip("THIS MONTH"),
          const SizedBox(width: 10),
          _buildFilterChip("CUSTOM"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = filter == label;
    return GestureDetector(
      onTap: () async {
        if (label == "CUSTOM") {
          await _pickCustomDateRange();
        }
        setState(() {
          filter = label;
        });
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D9488),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  color: const Color(0xFF0D9488),
                  child: filteredTransactions.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: _buildEmptyState(),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            return TransactionTile(
                              transaction: filteredTransactions[index],
                              textColor: const Color(0xFF1F2937),
                              useGlassEffect: false,
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: const Color(0xFF0D9488).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No transactions yet",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first transaction above",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddTransaction(bool isExpense) async {
    final added = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionForm(isExpense: isExpense, userId: 1),
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

    if (picked != null) {
      setState(() {
        customStartDate = picked.start;
        customEndDate = picked.end;
      });
    }
  }
}
