class Asset {
  final int? id;
  final String name;
  final String type;
  final DateTime purchaseDate;
  final String? assignedTo;
  final String status;

  Asset({
    this.id,
    required this.name,
    required this.type,
    required this.purchaseDate,
    this.assignedTo,
    required this.status,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      assignedTo: json['assignedTo'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final Map<String, dynamic> map = {
      'name': name,
      'type': type,
      // Format date as YYYY-MM-DD
      'purchaseDate':
          "${purchaseDate.year.toString().padLeft(4, '0')}-"
          "${purchaseDate.month.toString().padLeft(2, '0')}-"
          "${purchaseDate.day.toString().padLeft(2, '0')}",
      'assignedTo': assignedTo,
      'status': status,
    };
    if (includeId && id != null) {
      map['id'] = id!;
    }
    return map;
  }
}
