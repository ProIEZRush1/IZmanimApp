import 'package:flutter/material.dart';
import '../models/zman.dart';

class ZmanCard extends StatelessWidget {
  final Zman zman;
  final bool isNext;
  
  const ZmanCard({
    super.key,
    required this.zman,
    this.isNext = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isNext ? theme.colorScheme.secondaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNext 
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary.withOpacity(0.2),
          child: Icon(
            _getIconForZman(zman.key),
            color: isNext
                ? theme.colorScheme.onSecondary
                : theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          zman.getDisplayName(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          zman.time ?? '--:--',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isNext ? theme.colorScheme.secondary : null,
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForZman(String key) {
    // Handle old and new key formats
    if (key.contains('chatzotNight') || key.contains('chatzot_layla')) {
      return Icons.nights_stay;
    } else if (key.contains('alotHaShachar') || key.contains('alot_hashachar')) {
      return Icons.brightness_3;
    } else if (key.contains('misheyakir')) {
      return Icons.visibility;
    } else if (key.contains('dawn')) {
      return Icons.brightness_5;
    } else if (key.contains('sunrise')) {
      return Icons.wb_sunny;
    } else if (key.contains('sofZmanShma') || key.contains('sof_zman_shema')) {
      return Icons.menu_book;
    } else if (key.contains('sofZmanTfilla') || key.contains('sof_zman_tefillah')) {
      return Icons.people;
    } else if (key == 'chatzot') {
      return Icons.timelapse;
    } else if (key.contains('minchaGedola') || key.contains('mincha_gedolah')) {
      return Icons.access_time;
    } else if (key.contains('minchaKetana') || key.contains('mincha_ketanah')) {
      return Icons.timer;
    } else if (key.contains('plagHaMincha') || key.contains('plag_hamincha')) {
      return Icons.schedule;
    } else if (key.contains('sunset')) {
      return Icons.wb_twilight;
    } else if (key.contains('beinHaShmashos')) {
      return Icons.gradient;
    } else if (key.contains('dusk')) {
      return Icons.nights_stay;
    } else if (key.contains('tzeit') || key.contains('tzeis_hakochavim')) {
      return Icons.star;
    } else {
      return Icons.access_time;
    }
  }
}