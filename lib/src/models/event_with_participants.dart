class EventWithParticipants {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String targetAudience;
  final String status;
  final String type;
  final String? banner;
  final List<Participant> participants;

  EventWithParticipants({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.targetAudience,
    required this.status,
    required this.type,
    this.banner,
    required this.participants,
  });

  factory EventWithParticipants.fromJson(Map<String, dynamic> json) {
    return EventWithParticipants(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'],
      targetAudience: json['targetAudience'],
      status: json['status'],
      type: json['type'],
      banner: json['banner'],
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participant.fromJson(p))
          .toList(),
    );
  }
}

class Participant {
  final int id;
  final String userId;
  final int eventId;
  final DateTime registrationDate;
  final String status;
  final String role;

  Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registrationDate,
    required this.status,
    required this.role,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      userId: json['userId'],
      eventId: json['eventId'],
      registrationDate: DateTime.parse(json['registrationDate']),
      status: json['status'],
      role: json['role'],
    );
  }
}
