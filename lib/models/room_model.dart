class RoomModel {
  final String id;
  final String homeId;
  final String name;
  final String icon;
  final DateTime createdAt;
  int deviceCount;

  RoomModel({
    required this.id,
    required this.homeId,
    required this.name,
    required this.icon,
    required this.createdAt,
    this.deviceCount = 0,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      homeId: json['home_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deviceCount: json['device_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'home_id': homeId,
      'name': name,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
