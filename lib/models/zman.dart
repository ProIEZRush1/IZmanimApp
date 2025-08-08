class Zman {
  final String key;
  final String name;
  final String? translation;
  final String? time;

  Zman({
    required this.key,
    required this.name,
    this.translation,
    this.time,
  });

  factory Zman.fromJson(Map<String, dynamic> json) {
    return Zman(
      key: json['key'],
      name: json['name'],
      translation: json['translation'],
      time: json['time'],
    );
  }

  String getDisplayName() {
    // If there's a translation (for sunrise/sunset), show both
    if (translation != null) {
      return '$name - $translation';
    }
    return name;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'translation': translation,
      'time': time,
    };
  }
}