import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class AiInsightsScreen extends StatefulWidget {
  // final int userId;
  const AiInsightsScreen({
    super.key,
    // required this.userId
  });

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? analytics;
  TextEditingController _preferenceController = TextEditingController();
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
        // userId: widget.userId,
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
      appBar: AppBar(title: const Text("Insights"), centerTitle: true),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text("Error: $error"));
    }

    final trend = analytics!['trend'];
    final patterns = analytics!['patterns'];

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _sectionTitle("Monthly Trend"),
          const SizedBox(height: 12),
          _trendGrid(trend),

          const SizedBox(height: 24),
          _sectionTitle("Spending Pattern"),
          const SizedBox(height: 12),
          _patternCards(patterns),

          const SizedBox(height: 24),
          _sectionTitle("Spikes"),
          const SizedBox(height: 12),
          _spikesSection(analytics!['spikes']),

          const SizedBox(height: 12),
          _aiInputSection(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _trendGrid(Map<String, dynamic> trend) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _trendCard("Last Month", "${trend['previous_month_expense']}"),
        _trendCard("This Month", "${trend['current_month_expense']}"),
        _trendCard("Change", "${trend['change_percent']}%"),
        _trendCard("Trend", _formatTrend(trend['trend'])),
      ],
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  Widget _trendCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTrend(String trend) {
    switch (trend) {
      case "increase":
        return "Increase 🔺";
      case "decrease":
        return "Decrease 🔻";
      default:
        return "No Change";
    }
  }

  Widget _patternCards(Map<String, dynamic> patterns) {
    final bool weekendHeavy = patterns['weekend_heavy'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoCard(
                "Weekday Expense",
                "${patterns['weekday_expense']}",
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _infoCard(
                "Weekend Expense",
                "${patterns['weekend_expense']}",
                Icons.weekend,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _behaviorCard(
          weekendHeavy
              ? "You tend to spend more on weekends."
              : "Your spending is higher on weekdays.",
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _behaviorCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _spikesSection(List<dynamic> spikes) {
    if (spikes.isEmpty) {
      return _behaviorCard("No abnormal spikes detected this month.");
    }

    // Show top 2 spikes
    final topSpikes = spikes.take(2).toList();

    return Column(
      children: topSpikes.map((s) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${s['category']} spending increased by ${s['change_percent']}%",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _aiInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Get AI Suggestions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _preferenceController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:
                "Enter your preference (e.g., control spending in entertainment)",
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _callAiApi,
            child: isAiLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Get AI Suggestions"),
          ),
        ),
        const SizedBox(height: 12),
        if (aiResponse != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(aiResponse!),
          ),
      ],
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
        // userId: widget.userId,
        month: _currentMonth(),
        preference: Uri.encodeComponent(_preferenceController.text),
      );

      final decoded = res['ai_insights'];

      String output;

      if (decoded.containsKey('suggestions') &&
          decoded['suggestions'] is List) {
        output = (decoded['suggestions'] as List).join("\n");
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
