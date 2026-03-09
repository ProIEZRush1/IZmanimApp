import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_preference.dart';
import '../models/zman.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = 'notification_preferences';

  final NotificationService _service = NotificationService();
  List<NotificationPreference> _preferences = [];
  bool _permissionGranted = false;

  List<NotificationPreference> get preferences => _preferences;
  bool get permissionGranted => _permissionGranted;

  Future<void> initialize() async {
    await _service.initialize();
    await _loadPreferences();
  }

  Future<void> requestPermission() async {
    _permissionGranted = await _service.requestPermissions();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey);
    if (stored != null) {
      _preferences = stored
          .map((s) => NotificationPreference.fromJsonString(s))
          .toList();
      // Remove expired one-time notifications
      _preferences.removeWhere((p) =>
          p.scheduleType == ScheduleType.oneTime &&
          p.oneTimeDate != null &&
          p.oneTimeDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))));
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _preferences.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> addPreference(NotificationPreference preference) async {
    _preferences.add(preference);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> updatePreference(NotificationPreference preference) async {
    final index = _preferences.indexWhere((p) => p.id == preference.id);
    if (index != -1) {
      _preferences[index] = preference;
      await _savePreferences();
      notifyListeners();
    }
  }

  Future<void> removePreference(String id) async {
    _preferences.removeWhere((p) => p.id == id);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> togglePreference(String id) async {
    final pref = _preferences.firstWhere((p) => p.id == id);
    pref.enabled = !pref.enabled;
    await _savePreferences();
    notifyListeners();
  }

  bool isZmanSubscribed(String zmanKey) {
    return _preferences.any((p) => p.zmanKey == zmanKey && p.enabled);
  }

  Future<void> scheduleNotifications({
    required List<Zman> zmanim,
    required DateTime date,
    required String timezone,
    required String lang,
  }) async {
    if (_preferences.isEmpty) return;

    await _service.scheduleZmanNotifications(
      preferences: _preferences,
      zmanim: zmanim,
      date: date,
      timezone: timezone,
      lang: lang,
    );
  }
}
