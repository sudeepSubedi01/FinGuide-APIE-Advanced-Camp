class TransactionModel {
  final String categoryName;
  final String description;
  final String transactionType;
  final DateTime date;
  final double amount;

  TransactionModel({
    required this.categoryName,
    required this.description,
    required this.transactionType,
    required this.date,
    required this.amount,
  });

  bool get isExpense => transactionType.toLowerCase() == "expense";

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      categoryName: json['category'] != null
          ? json['category']['name'] ?? "Unknown"
          : "Uncategorized",
      description: json['description'] ?? "",
      transactionType: json['transaction_type'] ?? "",
      date: DateTime.parse(json['transaction_date']),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
