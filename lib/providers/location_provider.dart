import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart' as app_location;

class LocationProvider extends ChangeNotifier {
  app_location.Location? _currentLocation;
  bool _isLoading = false;
  String? _error;
  
  app_location.Location? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  LocationProvider() {
    _loadSavedLocation();
  }
  
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude');
    final lon = prefs.getDouble('longitude');
    final name = prefs.getString('location_name');
    final timezone = prefs.getString('timezone');
    
    if (lat != null && lon != null) {
      _currentLocation = app_location.Location(
        name: name ?? 'Custom Location',
        latitude: lat,
        longitude: lon,
        timezone: timezone ?? 'UTC',
      );
      notifyListeners();
    }
  }
  
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      String locationName = 'Current Location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        locationName = place.locality ?? place.name ?? 'Current Location';
      }
      
      _currentLocation = app_location.Location(
        name: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: DateTime.now().timeZoneName,
      );
      
      await _saveLocation(_currentLocation!);
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> setLocation(app_location.Location location) async {
    _currentLocation = location;
    await _saveLocation(location);
    notifyListeners();
  }
  
  Future<void> _saveLocation(app_location.Location location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', location.latitude);
    await prefs.setDouble('longitude', location.longitude);
    await prefs.setString('location_name', location.name);
    await prefs.setString('timezone', location.timezone);
  }
}