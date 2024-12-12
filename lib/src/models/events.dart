import 'package:event_management/src/service/logger_service.dart';

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
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'location': location,
      'targetAudience': targetAudience,
      'banner': banner,
      'status': status,
      'type': type,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    LoggerService.logger.i('Raw startDate from JSON: ${json['startDate']}');
    return Event(
      name: json['name'] ?? 'Unknown Name',
      idCreate: json['idCreate'] ?? 'Unknown ID',
      description: json['description'] ?? 'No description',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'] ?? 'Unknown Location',
      targetAudience: json['targetAudience'] ?? 'General',
      banner: json['banner'] ?? '',
      status: json['status'] ?? 'Pending',
      type: json['type'] ?? 'General',
    );
  }
  @override
  String toString() {
    return 'Event(name: $name, startDate: $startDate, endDate: $endDate)';
  }
}
