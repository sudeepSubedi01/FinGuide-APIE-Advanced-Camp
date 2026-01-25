import 'dart:ui';
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
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  color: Colors.white,
                  backgroundColor: const Color(0xFF0D9488),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildSectionTitle("Overall Balance"),
                        const SizedBox(height: 14),
                        _buildBalanceCards(totalIncome, totalExpense),
                        const SizedBox(height: 28),
                        _buildSectionTitle("This Month"),
                        const SizedBox(height: 14),
                        _buildBalanceCards(currentMonthIncome, currentMonthExpense),
                        const SizedBox(height: 28),
                        _buildSectionTitle("Expense Breakdown"),
                        const SizedBox(height: 14),
                        _buildExpenseBreakdownCard(),
                        const SizedBox(height: 28),
                        _buildSectionTitle("Income vs Expense Trend"),
                        const SizedBox(height: 14),
                        _buildChartCard(),
                        const SizedBox(height: 28),
                        _buildSectionTitle("Recent Transactions"),
                        const SizedBox(height: 14),
                        _buildTransactionsList(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.firstName ?? "User",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCards(double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: BalanceCard(
            title: "Income",
            amount: income.toStringAsFixed(0),
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: BalanceCard(
            title: "Expenses",
            amount: expense.toStringAsFixed(0),
            icon: Icons.trending_down_rounded,
            color: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownCard() {
    final colors = [
      const Color(0xFFF97316),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF22C55E),
      const Color(0xFFEAB308),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ExpensePieChart(categoryStats: categoryStats),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: categoryStats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stat.categoryName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: timelineStats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "No data available",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : IncomeExpenseBarChart(stats: timelineStats),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white.withOpacity(0.4),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No transactions yet",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: transactions
          .take(5)
          .map((tx) => TransactionTile(transaction: tx))
          .toList(),
    );
  }

  String formatDate(DateTime dt) => dt.toIso8601String().split('T')[0];
  DateTime rangeStart({int daysBack = 21}) =>
      DateTime.now().subtract(Duration(days: daysBack));
  DateTime rangeEnd() => DateTime.now();
}
