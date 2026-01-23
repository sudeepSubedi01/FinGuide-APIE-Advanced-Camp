class TimelineStat {
  final String date;
  final double income;
  final double expense;

  TimelineStat({
    required this.date,
    required this.income,
    required this.expense,
  });

  factory TimelineStat.fromJson(Map<String, dynamic> json) {
    return TimelineStat(
      date: json['date'],
      income: double.parse(json['income'].toString()),
      expense: double.parse(json['expense'].toString()),
    );
  }
}
