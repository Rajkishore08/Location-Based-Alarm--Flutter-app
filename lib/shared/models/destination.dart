class Destination {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String category; // 'home', 'work', 'college', 'transit', 'general'
  final String? iconName;
  final double? distanceMeters;

  const Destination({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.category = 'general',
    this.iconName,
    this.distanceMeters,
  });

  Destination copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? category,
    String? iconName,
    double? distanceMeters,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'iconName': iconName,
      'distanceMeters': distanceMeters,
    };
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'] as String? ?? 'general',
      iconName: json['iconName'] as String?,
      distanceMeters: json['distanceMeters'] != null ? (json['distanceMeters'] as num).toDouble() : null,
    );
  }
}
