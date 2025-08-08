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
          zman.name,
          style: TextStyle(
            fontWeight: zman.isPrimary ? FontWeight.bold : FontWeight.normal,
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
    switch (key) {
      case 'alot_hashachar':
        return Icons.brightness_3;
      case 'misheyakir':
        return Icons.visibility;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'sof_zman_shema':
        return Icons.menu_book;
      case 'sof_zman_tefillah':
        return Icons.people;
      case 'chatzot':
        return Icons.timelapse;
      case 'mincha_gedolah':
      case 'mincha_ketanah':
        return Icons.access_time;
      case 'plag_hamincha':
        return Icons.schedule;
      case 'sunset':
        return Icons.wb_twilight;
      case 'tzeis_hakochavim':
        return Icons.star;
      case 'chatzot_layla':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}