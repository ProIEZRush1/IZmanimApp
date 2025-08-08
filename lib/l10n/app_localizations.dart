import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Zmanim',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'settings': 'Settings',
      'location': 'Location',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'select_location': 'Select Location',
      'current_location': 'Current Location',
      'custom_location': 'Custom Location',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'search': 'Search',
      'no_zmanim': 'No times available',
      'error_loading': 'Error loading times',
      'retry': 'Retry',
      'about': 'About',
      'version': 'Version',
      'save': 'Save',
      'cancel': 'Cancel',
    },
    'es': {
      'app_title': 'Zmanim',
      'today': 'Hoy',
      'tomorrow': 'Mañana',
      'settings': 'Configuración',
      'location': 'Ubicación',
      'language': 'Idioma',
      'theme': 'Tema',
      'light': 'Claro',
      'dark': 'Oscuro',
      'system': 'Sistema',
      'select_location': 'Seleccionar Ubicación',
      'current_location': 'Ubicación Actual',
      'custom_location': 'Ubicación Personalizada',
      'latitude': 'Latitud',
      'longitude': 'Longitud',
      'search': 'Buscar',
      'no_zmanim': 'No hay horarios disponibles',
      'error_loading': 'Error al cargar horarios',
      'retry': 'Reintentar',
      'about': 'Acerca de',
      'version': 'Versión',
      'save': 'Guardar',
      'cancel': 'Cancelar',
    },
    'he': {
      'app_title': 'זמנים',
      'today': 'היום',
      'tomorrow': 'מחר',
      'settings': 'הגדרות',
      'location': 'מיקום',
      'language': 'שפה',
      'theme': 'ערכת נושא',
      'light': 'בהיר',
      'dark': 'כהה',
      'system': 'מערכת',
      'select_location': 'בחר מיקום',
      'current_location': 'מיקום נוכחי',
      'custom_location': 'מיקום מותאם אישית',
      'latitude': 'קו רוחב',
      'longitude': 'קו אורך',
      'search': 'חיפוש',
      'no_zmanim': 'אין זמנים זמינים',
      'error_loading': 'שגיאה בטעינת זמנים',
      'retry': 'נסה שוב',
      'about': 'אודות',
      'version': 'גרסה',
      'save': 'שמור',
      'cancel': 'ביטול',
    },
    'yi': {
      'app_title': 'זמנים',
      'today': 'היינט',
      'tomorrow': 'מארגן',
      'settings': 'איינשטעלונגען',
      'location': 'ארט',
      'language': 'שפראך',
      'theme': 'טעמע',
      'light': 'ליכט',
      'dark': 'טונקל',
      'system': 'סיסטעם',
      'select_location': 'אויסקלייבן ארט',
      'current_location': 'איצטיקער ארט',
      'custom_location': 'באזונדער ארט',
      'latitude': 'ברייט',
      'longitude': 'לענג',
      'search': 'זוכן',
      'no_zmanim': 'קיין זמנים',
      'error_loading': 'פעלער אין לאדן',
      'retry': 'פרובירן ווידער',
      'about': 'וועגן',
      'version': 'ווערסיע',
      'save': 'היט',
      'cancel': 'אָפּזאָגן',
    },
    'ar': {
      'app_title': 'الأوقات',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'settings': 'الإعدادات',
      'location': 'الموقع',
      'language': 'اللغة',
      'theme': 'المظهر',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'النظام',
      'select_location': 'اختر الموقع',
      'current_location': 'الموقع الحالي',
      'custom_location': 'موقع مخصص',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'search': 'بحث',
      'no_zmanim': 'لا توجد أوقات متاحة',
      'error_loading': 'خطأ في تحميل الأوقات',
      'retry': 'إعادة المحاولة',
      'about': 'حول',
      'version': 'الإصدار',
      'save': 'حفظ',
      'cancel': 'إلغاء',
    },
  };
  
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'he', 'yi', 'ar'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}