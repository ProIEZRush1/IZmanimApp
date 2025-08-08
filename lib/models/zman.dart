class Zman {
  final String key;
  final String name;
  final String? time;
  final bool isPrimary;

  Zman({
    required this.key,
    required this.name,
    this.time,
    this.isPrimary = false,
  });

  factory Zman.fromJson(Map<String, dynamic> json) {
    return Zman(
      key: json['key'],
      name: json['name'],
      time: json['time'],
      isPrimary: _isPrimaryZman(json['key']),
    );
  }

  static bool _isPrimaryZman(String key) {
    const primaryZmanim = [
      'alot_hashachar',
      'sunrise',
      'sof_zman_shema',
      'chatzot',
      'mincha_gedolah',
      'sunset',
      'tzeis_hakochavim',
    ];
    return primaryZmanim.contains(key);
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'time': time,
      'isPrimary': isPrimary,
    };
  }
}