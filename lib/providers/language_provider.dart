import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }
  
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'he':
        return 'עברית';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }
  
  TextDirection getTextDirection() {
    return ['he', 'ar'].contains(_currentLocale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}