import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zman.dart';
import '../models/location.dart';

class ApiService {
  static const String baseUrl = 'https://izmanim.overcloud.us/api';
  
  Future<List<Zman>> getZmanim({
    required double latitude,
    required double longitude,
    String? date,
    String timezone = 'UTC',
    String lang = 'en',
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'timezone': timezone,
        'lang': lang,
      };
      
      if (date != null) {
        queryParams['date'] = date;
      }
      
      final uri = Uri.parse('$baseUrl/zmanim').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final zmanimList = data['zmanim'] as List;
        return zmanimList.map((zman) => Zman.fromJson(zman)).toList();
      } else {
        throw Exception('Failed to load zmanim');
      }
    } catch (e) {
      throw Exception('Error fetching zmanim: $e');
    }
  }
  
  Future<List<Location>> getLocations({String lang = 'en'}) async {
    try {
      final uri = Uri.parse('$baseUrl/locations').replace(
        queryParameters: {'lang': lang},
      );
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final locationsList = data['locations'] as List;
        return locationsList.map((loc) => Location.fromJson(loc)).toList();
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      throw Exception('Error fetching locations: $e');
    }
  }
}