import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? analytics;
  final TextEditingController _preferenceController = TextEditingController();
  String? aiResponse;
  bool isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final now = DateTime.now();
      final res = await ApiService.getMonthlyAnalytics(
        year: now.year,
        month: now.month,
      );

      setState(() {
        analytics = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
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
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "AI Insights",
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

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (error != null) {
      return Center(
        child: _buildGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red[300],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Error loading insights",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final trend = analytics!['trend'];
    final patterns = analytics!['patterns'];

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      color: const Color(0xFF0D9488),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _buildSectionTitle("Monthly Trend", Icons.trending_up_rounded),
          const SizedBox(height: 14),
          _buildTrendGrid(trend),
          const SizedBox(height: 28),
          _buildSectionTitle("Spending Pattern", Icons.pie_chart_rounded),
          const SizedBox(height: 14),
          _buildPatternCards(patterns),
          const SizedBox(height: 28),
          _buildSectionTitle("Spending Spikes", Icons.warning_amber_rounded),
          const SizedBox(height: 14),
          _buildSpikesSection(analytics!['spikes']),
          const SizedBox(height: 28),
          _buildSectionTitle("AI Assistant", Icons.auto_awesome_rounded),
          const SizedBox(height: 14),
          _buildAiInputSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
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

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildTrendGrid(Map<String, dynamic> trend) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  "Last Month",
                  "\$${trend['previous_month_expense']}",
                  Icons.history_rounded,
                  Colors.blue[300]!,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildTrendItem(
                  "This Month",
                  "\$${trend['current_month_expense']}",
                  Icons.calendar_today_rounded,
                  Colors.green[300]!,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withOpacity(0.1)),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  "Change",
                  "${trend['change_percent']}%",
                  Icons.show_chart_rounded,
                  Colors.orange[300]!,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              Expanded(
                child: _buildTrendItem(
                  "Trend",
                  _formatTrend(trend['trend']),
                  trend['trend'] == 'increase'
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  trend['trend'] == 'increase'
                      ? Colors.red[300]!
                      : Colors.green[300]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  String _formatTrend(String trend) {
    switch (trend) {
      case "increase":
        return "Up";
      case "decrease":
        return "Down";
      default:
        return "Stable";
    }
  }

  Widget _buildPatternCards(Map<String, dynamic> patterns) {
    final bool weekendHeavy = patterns['weekend_heavy'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                "Weekday",
                "\$${patterns['weekday_expense']}",
                Icons.work_rounded,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildInfoCard(
                "Weekend",
                "\$${patterns['weekend_expense']}",
                Icons.weekend_rounded,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildInsightCard(
          weekendHeavy
              ? "You tend to spend more on weekends. Consider setting a weekend budget."
              : "Your spending is higher on weekdays. Review recurring subscriptions.",
          Icons.lightbulb_rounded,
          const Color(0xFFF97316),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text, IconData icon, Color color) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpikesSection(List<dynamic> spikes) {
    if (spikes.isEmpty) {
      return _buildInsightCard(
        "No abnormal spending spikes detected this month. Great job!",
        Icons.check_circle_rounded,
        const Color(0xFF22C55E),
      );
    }

    final topSpikes = spikes.take(2).toList();

    return Column(
      children: topSpikes.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInsightCard(
            "${s['category']} spending increased by ${s['change_percent']}%",
            Icons.warning_rounded,
            const Color(0xFFEF4444),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAiInputSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ask for personalized advice",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _preferenceController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "e.g., Help me reduce entertainment spending",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _callAiApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isAiLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          "Get AI Suggestions",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (aiResponse != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        color: Colors.blue[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "AI Response",
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    aiResponse!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _callAiApi() async {
    if (_preferenceController.text.isEmpty) return;

    setState(() {
      isAiLoading = true;
      aiResponse = null;
    });

    try {
      final res = await ApiService.getAiInsightsWithPreference(
        month: _currentMonth(),
        preference: Uri.encodeComponent(_preferenceController.text),
      );

      final decoded = res['ai_insights'];

      String output;

      if (decoded.containsKey('suggestions') &&
          decoded['suggestions'] is List) {
        output = (decoded['suggestions'] as List).join("\n\n");
      } else if (decoded.containsKey('error')) {
        output = "AI Error: ${decoded['error']}";
      } else {
        output = "Unexpected AI response";
      }

      setState(() {
        aiResponse = output;
        isAiLoading = false;
      });
    } catch (e) {
      setState(() {
        aiResponse = "Error: $e";
        isAiLoading = false;
      });
    }
  }
}
