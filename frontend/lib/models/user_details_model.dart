class UserDetails {
  final int userId;
  final String name;
  final String email;

  UserDetails({required this.userId, required this.name, required this.email});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  String get firstName => name.trim().split(' ').first;
}
