import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/zmanim_provider.dart';
import '../providers/location_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/zman_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/location_display.dart';
import 'settings_screen.dart';
import 'location_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadZmanim();
    });
  }

  Future<void> _loadZmanim() async {
    final locationProvider = context.read<LocationProvider>();
    final zmanimProvider = context.read<ZmanimProvider>();
    final langProvider = context.read<LanguageProvider>();
    
    if (locationProvider.currentLocation == null) {
      await locationProvider.getCurrentLocation();
    }
    
    if (locationProvider.currentLocation != null) {
      await zmanimProvider.loadZmanim(
        location: locationProvider.currentLocation!,
        language: langProvider.currentLocale.languageCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = context.watch<LanguageProvider>();
    
    return Directionality(
      textDirection: langProvider.getTextDirection(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            localizations.get('app_title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationScreen()),
                );
                _loadZmanim();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                _loadZmanim();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadZmanim,
          child: Consumer3<ZmanimProvider, LocationProvider, LanguageProvider>(
            builder: (context, zmanimProvider, locationProvider, langProvider, child) {
              return Column(
                children: [
                  const LocationDisplay(),
                  const DateSelector(),
                  Expanded(
                    child: _buildZmanimList(context, zmanimProvider, localizations),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildZmanimList(BuildContext context, ZmanimProvider provider, AppLocalizations localizations) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              localizations.get('error_loading'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadZmanim,
              child: Text(localizations.get('retry')),
            ),
          ],
        ),
      );
    }
    
    // Don't show "no times" if we haven't loaded anything yet
    final locationProvider = context.read<LocationProvider>();
    if (provider.zmanim.isEmpty) {
      if (locationProvider.currentLocation == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64),
              const SizedBox(height: 16),
              Text(
                localizations.get('select_location'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }
      return Center(
        child: Text(
          localizations.get('no_times_available'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    
    final nextZman = provider.getNextZman();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (nextZman != null) ...[
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Next:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextZman.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextZman.time ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...provider.zmanim.map((zman) => ZmanCard(
          zman: zman,
          isNext: zman == nextZman,
        )),
      ],
    );
  }
}