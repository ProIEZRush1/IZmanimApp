class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String timezone;

  Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}