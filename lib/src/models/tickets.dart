// ignore_for_file: non_constant_identifier_names

class Ticket {
  final int id;
  final int eventId;
  final String userId;
  final DateTime purchaseDate;
  final String qrCode;
  final String status;

  DateTime? cancellationStartDate;
  DateTime? cancellationEndDate;
  bool? isReasonImageRequired;
  bool? isLinkRequired;
  String? cancellationLink;
  String? cancel_status;

  // Private variables for name and photoUrl
  String _eventName = 'Unknown Event';
  String _eventBannerUrl =
      'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
  String _startDate = "Unknown Start Date";
  String _endDate = "Unknown End Date";
  String _eventStatus = "Pending";

  // Constructor
  Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.purchaseDate,
    required this.qrCode,
    required this.status,
    this.cancellationStartDate,
    this.cancellationEndDate,
    this.isReasonImageRequired = false,
    this.isLinkRequired = false,
    this.cancellationLink,
    this.cancel_status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      qrCode: json['qrCode'],
      status: json['status'],
      cancellationStartDate: json['cancellationStartDate'] != null
          ? DateTime.parse(json['cancellationStartDate'])
          : null,
      cancellationEndDate: json['cancellationEndDate'] != null
          ? DateTime.parse(json['cancellationEndDate'])
          : null,
      isReasonImageRequired: json['isReasonImageRequired'] ?? false,
      isLinkRequired: json['isLinkRequired'] ?? false,
      cancellationLink: json['cancellationLink'],
      cancel_status: json['cancel_status'],
    );
  }

  String get eventName => _eventName;

  set eventName(String newName) {
    if (newName.isNotEmpty) {
      _eventName = newName;
    } else {
      _eventName = 'Unknown Event';
    }
  }

  String get eventBannerUrl => _eventBannerUrl;

  set eventBannerUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      _eventBannerUrl = newUrl;
    } else {
      _eventBannerUrl =
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
    }
  }

  String get startDate => _startDate;

  set startDate(String newStartDate) {
    if (newStartDate.isNotEmpty) {
      _startDate = newStartDate;
    } else {
      newStartDate = 'Unknown Start Date';
    }
  }

  String get endDate => _endDate;

  set endDate(String newEndDate) {
    if (newEndDate.isNotEmpty) {
      _endDate = newEndDate;
    } else {
      newEndDate = 'Unknown Start Date';
    }
  }

  String get eventStatus => _eventStatus;

  set eventStatus(String newEventStatus) {
    if (newEventStatus.isNotEmpty) {
      _eventStatus = newEventStatus;
    } else {
      newEventStatus = 'Unknown Start Date';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'qrCode': qrCode,
      'status': status,
      'eventName': eventName,
      'eventBannerUrl': eventBannerUrl,
      'startDate': startDate,
      'cancellationStartDate': cancellationStartDate?.toIso8601String(),
      'cancellationEndDate': cancellationEndDate?.toIso8601String(),
      'isReasonImageRequired': isReasonImageRequired,
      'isLinkRequired': isLinkRequired,
      'cancellationLink': cancellationLink,
      'cancel_status': cancel_status ?? "None",
    };
  }
}
