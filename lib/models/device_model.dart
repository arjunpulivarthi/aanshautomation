enum DeviceType {
  light,
  thermostat,
  lock,
  camera,
  sensor;

  static DeviceType fromString(String value) {
    return DeviceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DeviceType.sensor,
    );
  }
}

class DeviceModel {
  final String id;
  final String roomId;
  final String name;
  final DeviceType type;
  final String? mqttTopic;
  final String? hardwareId;
  final bool isOnline;
  final Map<String, dynamic> currentState;
  final DateTime createdAt;

  DeviceModel({
    required this.id,
    required this.roomId,
    required this.name,
    required this.type,
    this.mqttTopic,
    this.hardwareId,
    required this.isOnline,
    required this.currentState,
    required this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      name: json['name'] as String,
      type: DeviceType.fromString(json['type'] as String),
      mqttTopic: json['mqtt_topic'] as String?,
      hardwareId: json['hardware_id'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      currentState: json['current_state'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'name': name,
      'type': type.name,
      'mqtt_topic': mqttTopic,
      'hardware_id': hardwareId,
      'is_online': isOnline,
      'current_state': currentState,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods for specific device types
  bool get isOn => currentState['is_on'] as bool? ?? false;
  int get brightness => currentState['brightness'] as int? ?? 0;
  double get temperature => (currentState['temperature'] as num?)?.toDouble() ?? 20.0;
  bool get isLocked => currentState['is_locked'] as bool? ?? true;
}
