import 'destination.dart';

class SavedPlace {
  final String id;
  final String name;
  final String category; // 'home', 'work', 'college', 'station', 'other'
  final Destination destination;
  final bool isFavorite;
  final DateTime createdAt;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.destination,
    this.isFavorite = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'destination': destination.toJson(),
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        destination: Destination.fromJson(json['destination'] as Map<String, dynamic>),
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
