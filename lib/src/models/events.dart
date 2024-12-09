class Event {
  String name;
  String idCreate;
  String description;
  DateTime startDate;
  DateTime endDate;
  String location;
  String targetAudience;
  String banner;
  String status;
  String type;

  Event({
    required this.name,
    required this.idCreate,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.targetAudience,
    required this.banner,
    required this.status,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idCreate': idCreate,
      'description': description,
      'startDate': startDate.toUtc().toIso8601String(), // Chuyển đổi về UTC và định dạng ISO 8601
      'endDate': endDate.toUtc().toIso8601String(),     // Chuyển đổi về UTC và định dạng ISO 8601
      'location': location,
      'targetAudience': targetAudience,
      'banner': banner,
      'status': status,
      'type': type,
    };
  }
}
