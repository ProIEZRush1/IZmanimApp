import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/zmanim_provider.dart';
import '../providers/location_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});
  
  @override
  Widget build(BuildContext context) {
    final zmanimProvider = context.watch<ZmanimProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = zmanimProvider.selectedDate;
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && 
                    selectedDate.month == now.month && 
                    selectedDate.day == now.day;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () async {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              zmanimProvider.setDate(newDate);
              if (locationProvider.currentLocation != null) {
                await zmanimProvider.loadZmanim(
                  location: locationProvider.currentLocation!,
                  language: langProvider.currentLocale.languageCode,
                );
              }
            },
          ),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              
              if (pickedDate != null && locationProvider.currentLocation != null) {
                zmanimProvider.setDate(pickedDate);
                await zmanimProvider.loadZmanim(
                  location: locationProvider.currentLocation!,
                  language: langProvider.currentLocale.languageCode,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isToday 
                        ? localizations.get('today')
                        : _formatDate(selectedDate, langProvider.currentLocale.languageCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () async {
              final newDate = selectedDate.add(const Duration(days: 1));
              zmanimProvider.setDate(newDate);
              if (locationProvider.currentLocation != null) {
                await zmanimProvider.loadZmanim(
                  location: locationProvider.currentLocation!,
                  language: langProvider.currentLocale.languageCode,
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date, String languageCode) {
    switch (languageCode) {
      case 'he':
      case 'yi':
        return DateFormat('d בMMMM yyyy', 'he').format(date);
      case 'ar':
        return DateFormat('d MMMM yyyy', 'ar').format(date);
      case 'es':
        return DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(date);
      default:
        return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}