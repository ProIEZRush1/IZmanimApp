import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/notification_preference.dart';
import '../models/zman.dart';
import '../providers/language_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/zmanim_provider.dart';
import '../services/api_service.dart';
import '../widgets/add_notification_sheet.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final ApiService _apiService = ApiService();
  List<Zman> _todayZmanim = [];
  bool _loadingZmanim = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().requestPermission();
      _loadTodayZmanim();
    });
  }

  Future<void> _loadTodayZmanim() async {
    final locationProvider = context.read<LocationProvider>();
    final langProvider = context.read<LanguageProvider>();

    if (locationProvider.currentLocation == null) {
      await locationProvider.getCurrentLocation();
    }

    final location = locationProvider.currentLocation;
    if (location == null) return;

    setState(() {
      _loadingZmanim = true;
      _loadError = null;
    });

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final zmanim = await _apiService.getZmanim(
        latitude: location.latitude,
        longitude: location.longitude,
        date: today,
        timezone: location.timezone,
        lang: langProvider.currentLocale.languageCode,
      );
      if (mounted) {
        setState(() {
          _todayZmanim = zmanim;
          _loadingZmanim = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingZmanim = false;
          _loadError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = context.watch<LanguageProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    return Directionality(
      textDirection: langProvider.getTextDirection(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.get('notifications')),
        ),
        floatingActionButton: _loadingZmanim
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddNotification(context),
                child: const Icon(Icons.add),
              ),
        body: _loadingZmanim
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            localizations.get('error_loading'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadError!,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTodayZmanim,
                            child: Text(localizations.get('retry')),
                          ),
                        ],
                      ),
                    ),
                  )
                : notifProvider.preferences.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.get('no_notifications'),
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.get('add_notification_hint'),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: notifProvider.preferences.length,
                    itemBuilder: (context, index) {
                      final pref = notifProvider.preferences[index];
                      return _buildNotificationTile(
                          context, pref, notifProvider, localizations);
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationPreference pref,
    NotificationProvider provider,
    AppLocalizations localizations,
  ) {
    final subtitle = _buildSubtitle(pref, localizations);

    return Dismissible(
      key: Key(pref.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.removePreference(pref.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pref.enabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.notifications_active,
            color: pref.enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        title: Text(
          pref.zmanName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: pref.enabled ? null : Theme.of(context).disabledColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: pref.enabled ? null : Theme.of(context).disabledColor,
          ),
        ),
        trailing: Switch(
          value: pref.enabled,
          onChanged: (_) => provider.togglePreference(pref.id),
        ),
        onTap: () => _showEditNotification(context, pref),
      ),
    );
  }

  String _buildSubtitle(
      NotificationPreference pref, AppLocalizations localizations) {
    final parts = <String>[];

    if (pref.minutesBefore > 0) {
      parts.add(
          '${pref.minutesBefore} ${localizations.get('minutes_before')}');
    } else {
      parts.add(localizations.get('at_time'));
    }

    switch (pref.scheduleType) {
      case ScheduleType.daily:
        parts.add(localizations.get('every_day'));
        break;
      case ScheduleType.weekdays:
        final dayNames = pref.selectedWeekdays
            .map((d) => _getShortDayName(d, localizations))
            .join(', ');
        parts.add(dayNames);
        break;
      case ScheduleType.oneTime:
        if (pref.oneTimeDate != null) {
          parts.add(
              '${pref.oneTimeDate!.day}/${pref.oneTimeDate!.month}/${pref.oneTimeDate!.year}');
        }
        break;
    }

    return parts.join(' · ');
  }

  String _getShortDayName(int weekday, AppLocalizations localizations) {
    final keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return localizations.get(keys[weekday - 1]);
  }

  void _showAddNotification(BuildContext context) {
    if (_todayZmanim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.get('error_loading')),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddNotificationSheet(
        zmanim: _todayZmanim,
      ),
    );
  }

  void _showEditNotification(
      BuildContext context, NotificationPreference pref) {
    final zmanim = _todayZmanim.isNotEmpty
        ? _todayZmanim
        : context.read<ZmanimProvider>().zmanim;

    if (zmanim.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddNotificationSheet(
        zmanim: zmanim,
        existingPreference: pref,
      ),
    );
  }
}
