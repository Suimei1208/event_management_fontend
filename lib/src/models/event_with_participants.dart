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
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No name available',
      description: json['description'] ?? 'No description available',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      location: json['location'] ?? 'No location available',
      targetAudience: json['targetAudience'] ?? 'No target audience available',
      status: json['status'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
      banner: json['banner'],
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => Participant.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'targetAudience': targetAudience,
      'status': status,
      'type': type,
      'banner': banner,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
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
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 'Unknown',
      eventId: json['eventId'] ?? 0,
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : DateTime.now(),
      status: json['status'] ?? 'Unknown',
      role: json['role'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'registrationDate': registrationDate.toIso8601String(),
      'status': status,
      'role': role,
    };
  }
}
