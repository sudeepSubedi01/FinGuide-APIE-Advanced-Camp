import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final Color? textColor;
  final bool useGlassEffect;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.textColor,
    this.useGlassEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final accentColor = isExpense ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
    final isDark = textColor == null || textColor == Colors.white;

    Widget content = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              )
            : null,
        color: isDark ? null : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.25),
                  accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    color: (textColor ?? Colors.white).withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(transaction.date),
                style: TextStyle(
                  color: (textColor ?? Colors.white).withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (useGlassEffect && isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: content,
        ),
      );
    }

    return content;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
