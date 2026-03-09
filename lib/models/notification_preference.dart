import 'dart:convert';

enum ScheduleType { daily, weekdays, oneTime }

class NotificationPreference {
  final String id;
  final String zmanKey;
  final String zmanName;
  final int minutesBefore;
  final ScheduleType scheduleType;
  final List<int> selectedWeekdays; // 1=Mon, 7=Sun (for weekdays type)
  final DateTime? oneTimeDate; // for oneTime type
  bool enabled;

  NotificationPreference({
    required this.id,
    required this.zmanKey,
    required this.zmanName,
    this.minutesBefore = 0,
    this.scheduleType = ScheduleType.daily,
    this.selectedWeekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.oneTimeDate,
    this.enabled = true,
  });

  bool shouldNotifyOn(DateTime date) {
    if (!enabled) return false;

    switch (scheduleType) {
      case ScheduleType.daily:
        return true;
      case ScheduleType.weekdays:
        return selectedWeekdays.contains(date.weekday);
      case ScheduleType.oneTime:
        if (oneTimeDate == null) return false;
        return date.year == oneTimeDate!.year &&
            date.month == oneTimeDate!.month &&
            date.day == oneTimeDate!.day;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zmanKey': zmanKey,
      'zmanName': zmanName,
      'minutesBefore': minutesBefore,
      'scheduleType': scheduleType.index,
      'selectedWeekdays': selectedWeekdays,
      'oneTimeDate': oneTimeDate?.toIso8601String(),
      'enabled': enabled,
    };
  }

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] as String,
      zmanKey: json['zmanKey'] as String,
      zmanName: json['zmanName'] as String,
      minutesBefore: json['minutesBefore'] as int? ?? 0,
      scheduleType: ScheduleType.values[json['scheduleType'] as int? ?? 0],
      selectedWeekdays: (json['selectedWeekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      oneTimeDate: json['oneTimeDate'] != null
          ? DateTime.parse(json['oneTimeDate'] as String)
          : null,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationPreference.fromJsonString(String jsonString) {
    return NotificationPreference.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
