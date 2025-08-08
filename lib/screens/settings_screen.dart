import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Directionality(
      textDirection: langProvider.getTextDirection(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.get('settings')),
        ),
        body: ListView(
          children: [
            _buildLanguageSection(context, localizations, langProvider),
            const Divider(),
            _buildThemeSection(context, localizations, themeProvider),
            const Divider(),
            _buildAboutSection(context, localizations),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSection(BuildContext context, AppLocalizations localizations, LanguageProvider provider) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(localizations.get('language')),
      subtitle: Text(provider.getLanguageName(provider.currentLocale.languageCode)),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.get('language')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(context, provider, 'en', 'English'),
                  _buildLanguageOption(context, provider, 'es', 'Español'),
                  _buildLanguageOption(context, provider, 'he', 'עברית'),
                  _buildLanguageOption(context, provider, 'yi', 'יידיש'),
                  _buildLanguageOption(context, provider, 'ar', 'العربية'),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildLanguageOption(BuildContext context, LanguageProvider provider, String code, String name) {
    final isSelected = provider.currentLocale.languageCode == code;
    
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        provider.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildThemeSection(BuildContext context, AppLocalizations localizations, ThemeProvider provider) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: Text(localizations.get('theme')),
      subtitle: Text(_getThemeName(localizations, provider.themeMode)),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.get('theme')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(context, provider, ThemeMode.light, localizations.get('light')),
                  _buildThemeOption(context, provider, ThemeMode.dark, localizations.get('dark')),
                  _buildThemeOption(context, provider, ThemeMode.system, localizations.get('system')),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildThemeOption(BuildContext context, ThemeProvider provider, ThemeMode mode, String name) {
    final isSelected = provider.themeMode == mode;
    
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
  
  String _getThemeName(AppLocalizations localizations, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.get('light');
      case ThemeMode.dark:
        return localizations.get('dark');
      case ThemeMode.system:
        return localizations.get('system');
    }
  }
  
  Widget _buildAboutSection(BuildContext context, AppLocalizations localizations) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(localizations.get('about')),
      subtitle: Text('${localizations.get('version')} 1.0.0'),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: localizations.get('app_title'),
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2024 Zmanim App',
        );
      },
    );
  }
}