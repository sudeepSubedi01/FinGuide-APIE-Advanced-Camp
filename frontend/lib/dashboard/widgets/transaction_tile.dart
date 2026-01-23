import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: transaction.isExpense
            ? Colors.red.withAlpha(40)
            : Colors.green.withAlpha(40),
        child: Icon(
          transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
          color: transaction.isExpense ? Colors.red : Colors.green,
          size: 18,
        ),
      ),
      title: Text(
        transaction.categoryName,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        transaction.description, 
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: Text(
        (transaction.isExpense ? "- " : "+ ") +
            transaction.amount.toStringAsFixed(2), 
        style: TextStyle(
          color: transaction.isExpense ? Colors.red : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
