import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/location.dart' as app_location;
import '../services/api_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final ApiService _apiService = ApiService();
  List<app_location.Location> _presetLocations = [];
  bool _isLoadingPresets = false;
  
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadPresetLocations();
  }
  
  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPresetLocations() async {
    setState(() {
      _isLoadingPresets = true;
    });
    
    try {
      final langProvider = context.read<LanguageProvider>();
      _presetLocations = await _apiService.getLocations(
        lang: langProvider.currentLocale.languageCode,
      );
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingPresets = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = context.watch<LanguageProvider>();
    final locationProvider = context.watch<LocationProvider>();
    
    return Directionality(
      textDirection: langProvider.getTextDirection(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.get('location')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.my_location),
                title: Text(localizations.get('current_location')),
                subtitle: locationProvider.currentLocation != null
                    ? Text(locationProvider.currentLocation!.name)
                    : null,
                trailing: locationProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: locationProvider.isLoading
                    ? null
                    : () async {
                        await locationProvider.getCurrentLocation();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.get('select_location'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_isLoadingPresets)
              const Center(child: CircularProgressIndicator())
            else
              ..._presetLocations.map((location) => Card(
                    child: ListTile(
                      title: Text(location.name),
                      subtitle: Text(
                        '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      ),
                      trailing: locationProvider.currentLocation?.name == location.name
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        locationProvider.setLocation(location);
                        Navigator.pop(context);
                      },
                    ),
                  )),
            const SizedBox(height: 24),
            Text(
              localizations.get('custom_location'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: InputDecoration(
                        labelText: localizations.get('latitude'),
                        hintText: '31.7683',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lonController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: InputDecoration(
                        labelText: localizations.get('longitude'),
                        hintText: '35.2137',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        final lat = double.tryParse(_latController.text);
                        final lon = double.tryParse(_lonController.text);
                        
                        if (lat != null && lon != null) {
                          if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
                            locationProvider.setLocation(
                              app_location.Location(
                                name: localizations.get('custom_location'),
                                latitude: lat,
                                longitude: lon,
                                timezone: DateTime.now().timeZoneName,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid coordinates'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid numbers'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: Text(localizations.get('save')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}