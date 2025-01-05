class Spending {
  final String id;
  final String category;
  final double amount;
  final int eventId;

  Spending(
      {required this.id,
      required this.category,
      required this.amount,
      required this.eventId});

  factory Spending.fromJson(Map<String, dynamic> json) {
    return Spending(
        id: json['_id'],
        category: json['category'],
        amount: json['amount'],
        eventId: json['eventId']);
  }
}
