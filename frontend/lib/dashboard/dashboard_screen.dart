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
  double currentMonthIncome = 0;
  double currentMonthExpense = 0;
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  List<TimelineStat> timelineStats = [];
  List<CategoryStat> categoryStats = [];
  UserDetails? currentUser;
  late final DateTime startOfMonth;
  late final DateTime endOfMonth;

  @override
  void initState() {
    super.initState();

    startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    endOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final startDate = rangeStart(daysBack: 30);
      final endDate = rangeEnd();

      final summary = await ApiService.getSummary();
      final categories = await ApiService.getCategoryStats(
        startDate: startOfMonth.toIso8601String().split('T')[0],
        endDate: endOfMonth.toIso8601String().split('T')[0],
      );

      final timeline = await ApiService.getTimelineStats(
        startDate: formatDate(startDate),
        endDate: formatDate(endDate),
      );

      final userInfo = await ApiService.getCurrentUser(userId: 1);
      final txs = await ApiService.getTransactions(1);

      setState(() {
        totalIncome = double.parse(summary['total_income'].toString());
        totalExpense = double.parse(summary['total_expense'].toString());
        currentMonthIncome = double.parse(
          summary['current_month_income'].toString(),
        );
        currentMonthExpense = double.parse(
          summary['current_month_expense'].toString(),
        );
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

                    // OVERALL BALANCE CARDS
                    const Text(
                      "Overall Income Vs Expense",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title: "Income",
                            amount: totalIncome.toStringAsFixed(0),
                            icon: Icons.trending_up,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BalanceCard(
                            title: "Expenses",
                            amount: totalExpense.toStringAsFixed(0),
                            icon: Icons.trending_down,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // CURRENT MONTH BALANCE CARDS
                    const Text(
                      "Current Month",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title: "Income",
                            amount: currentMonthIncome.toStringAsFixed(0),
                            icon: Icons.trending_up,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BalanceCard(
                            title: "Expenses",
                            amount: currentMonthExpense.toStringAsFixed(0),
                            icon: Icons.trending_down,
                            color: Colors.redAccent,
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

  String formatDate(DateTime dt) => dt.toIso8601String().split('T')[0];
  DateTime rangeStart({int daysBack = 21}) =>
      DateTime.now().subtract(Duration(days: daysBack));
  DateTime rangeEnd() => DateTime.now();
}
