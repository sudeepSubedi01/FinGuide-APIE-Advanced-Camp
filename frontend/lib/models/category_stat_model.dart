class CategoryStat {
  final String categoryName;
  final double expense;

  CategoryStat({
    required this.categoryName,
    required this.expense,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      categoryName: json['category_name'],
      expense: double.parse(json['expense'].toString()),
    );
  }
}
