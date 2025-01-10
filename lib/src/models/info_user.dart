class InfoUser {
  final String id;
  final String name;
  final String nameFromEmail;
  final String email;
  final String avtUrl;

  InfoUser({
    required this.id,
    required this.name,
    required this.nameFromEmail,
    required this.email,
    required this.avtUrl,
  });

  factory InfoUser.fromJson(Map<String, dynamic> json) {
    return InfoUser(
      id: json['id'],
      name: json['name'],
      nameFromEmail: json['nameFromEmail'],
      email: json['email'],
      avtUrl: json['avtUrl'],
    );
  }
}
