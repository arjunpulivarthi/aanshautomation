class HomeModel {
  final String id;
  final String name;
  final String address;
  final String wifiSsid;
  final DateTime createdAt;

  HomeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.wifiSsid,
    required this.createdAt,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      wifiSsid: json['wifi_ssid'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'wifi_ssid': wifiSsid,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
