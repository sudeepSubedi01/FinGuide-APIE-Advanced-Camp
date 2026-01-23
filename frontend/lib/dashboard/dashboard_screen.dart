import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/timeline_stat_model.dart';
import '../models/category_stat_model.dart';
import '../models/user_details_model.dart';
import '../services/api_service.dart';
import 'widgets/balance_card.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/expense_pie_chart.dart';
import 'widgets/income_expense_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalIncome = 0;
  double totalExpense = 0;
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  List<TimelineStat> timelineStats = [];
  List<CategoryStat> categoryStats = [];
  UserDetails? currentUser;

  @override
  void initState() {
    super.initState();
    // debugPrint("Dashboard initState called");
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // debugPrint("_loadDashboardData called");
    try {
      final summary = await ApiService.getSummary(1);
      // print(summary);
      final txs = await ApiService.getTransactions(1);
      final timeline = await ApiService.getTimelineStats(
        userId: 1,
        startDate: "2025-12-25",
        endDate: "2026-01-01",
      );
      final categories = await ApiService.getCategoryStats(
        userId: 1,
        startDate: "2025-12-25",
        endDate: "2026-01-01",
      );
      final userInfo = await ApiService.getCurrentUser(userId: 1);

      setState(() {
        totalIncome = double.parse(summary['total_income'].toString());
        totalExpense = double.parse(summary['total_expense'].toString());
        transactions = txs;
        isLoading = false;
        timelineStats = timeline;
        categoryStats = categories;
        currentUser = userInfo;
      });
    } catch (e, stack) {
      debugPrint("Dashboard error: $e");
      debugPrint(stack.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008080),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Text(
                      "Welcome, ${currentUser!.firstName} 🙇",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here’s your financial overview",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 24),

                    // BALANCE CARDS
                    Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title: "Income",
                            amount: "₹ ${totalIncome.toStringAsFixed(0)}",
                            // amount: "50000",
                            icon: Icons.trending_up,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BalanceCard(
                            title: "Expenses",
                            amount: "₹ ${totalExpense.toStringAsFixed(0)}",
                            icon: Icons.trending_down,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // EXPENSE BREAKDOWN
                    const Text(
                      "Expense Breakdown",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ExpensePieChart(categoryStats: categoryStats),
                          SizedBox(height: 12),
                          Column(
                            children: categoryStats.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final stat = entry.value;
                              final colors = [
                                Colors.orange,
                                Colors.blue,
                                Colors.red,
                                Colors.purple,
                                Colors.green,
                                Colors.yellow,
                              ];
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: colors[index % colors.length],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    stat.categoryName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Income vs Expense",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (timelineStats.isEmpty)
                      const Text(
                        "No data",
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      IncomeExpenseBarChart(stats: timelineStats),

                    const SizedBox(height: 24),

                    // RECENT TRANSACTIONS
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (transactions.isEmpty)
                      const Text(
                        "No transactions found",
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ...transactions
                          .map((tx) => TransactionTile(transaction: tx))
                          .toList(),
                  ],
                ),
              ),
      ),
    );
  }
}
