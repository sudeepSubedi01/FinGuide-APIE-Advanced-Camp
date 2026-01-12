class Currency {
  final String code;
  final String name;
  final String country;
  final String countryCode;
  final String flagBase64;

  Currency({
    required this.code,
    required this.name,
    required this.country,
    required this.countryCode,
    required this.flagBase64,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      country: json['country'],
      countryCode: json['countryCode'],
      flagBase64: json['flag'],
    );
  }
}
