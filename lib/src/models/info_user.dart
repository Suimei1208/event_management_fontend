class User {
  final String id;
  final String name;
  final String nameFromEmail;
  final String email;
  final String avtUrl;

  User({
    required this.id,
    required this.name,
    required this.nameFromEmail,
    required this.email,
    required this.avtUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nameFromEmail: json['nameFromEmail'],
      email: json['email'],
      avtUrl: json['avtUrl'],
    );
  }
}
