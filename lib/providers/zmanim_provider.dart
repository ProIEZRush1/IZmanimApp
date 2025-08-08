import 'package:flutter/material.dart';
import '../models/zman.dart';
import '../models/location.dart';
import '../services/api_service.dart';

class ZmanimProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Zman> _zmanim = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  
  List<Zman> get zmanim => _zmanim;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  
  List<Zman> get primaryZmanim => _zmanim.where((z) => z.isPrimary).toList();
  List<Zman> get secondaryZmanim => _zmanim.where((z) => !z.isPrimary).toList();
  
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  Future<void> loadZmanim({
    required Location location,
    required String language,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _zmanim = await _apiService.getZmanim(
        latitude: location.latitude,
        longitude: location.longitude,
        date: _selectedDate.toIso8601String().split('T')[0],
        timezone: location.timezone,
        lang: language,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _zmanim = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Zman? getNextZman() {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    final selectedStr = _selectedDate.toIso8601String().split('T')[0];
    
    if (todayStr != selectedStr) return null;
    
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (final zman in _zmanim) {
      if (zman.time != null && zman.time!.compareTo(currentTime) > 0) {
        return zman;
      }
    }
    
    return null;
  }
}