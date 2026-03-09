import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/notification_preference.dart';
import '../models/zman.dart';
import '../providers/language_provider.dart';
import '../providers/notification_provider.dart';

class AddNotificationSheet extends StatefulWidget {
  final List<Zman> zmanim;
  final NotificationPreference? existingPreference;

  const AddNotificationSheet({
    super.key,
    required this.zmanim,
    this.existingPreference,
  });

  @override
  State<AddNotificationSheet> createState() => _AddNotificationSheetState();
}

class _AddNotificationSheetState extends State<AddNotificationSheet> {
  late String _selectedZmanKey;
  late String _selectedZmanName;
  late int _minutesBefore;
  late ScheduleType _scheduleType;
  late List<int> _selectedWeekdays;
  DateTime? _oneTimeDate;

  final _minutesOptions = [0, 5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPreference;
    if (existing != null) {
      _selectedZmanKey = existing.zmanKey;
      _selectedZmanName = existing.zmanName;
      _minutesBefore = existing.minutesBefore;
      _scheduleType = existing.scheduleType;
      _selectedWeekdays = List.from(existing.selectedWeekdays);
      _oneTimeDate = existing.oneTimeDate;
    } else {
      final firstWithTime =
          widget.zmanim.where((z) => z.time != null).firstOrNull;
      _selectedZmanKey = firstWithTime?.key ?? widget.zmanim.first.key;
      _selectedZmanName =
          firstWithTime?.getDisplayName() ?? widget.zmanim.first.getDisplayName();
      _minutesBefore = 10;
      _scheduleType = ScheduleType.daily;
      _selectedWeekdays = [1, 2, 3, 4, 5, 6, 7];
      _oneTimeDate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = context.watch<LanguageProvider>();
    final theme = Theme.of(context);
    final isEditing = widget.existingPreference != null;

    return Directionality(
      textDirection: langProvider.getTextDirection(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? localizations.get('edit_notification')
                    : localizations.get('add_notification'),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Zman selector
              Text(
                localizations.get('select_zman'),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedZmanKey,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: widget.zmanim
                    .where((z) => z.time != null)
                    .map((z) => DropdownMenuItem(
                          value: z.key,
                          child: Text(
                            '${z.getDisplayName()} (${z.time})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    final zman = widget.zmanim.firstWhere((z) => z.key == value);
                    setState(() {
                      _selectedZmanKey = value;
                      _selectedZmanName = zman.getDisplayName();
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Minutes before
              Text(
                localizations.get('remind_before'),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _minutesOptions.map((mins) {
                  final isSelected = _minutesBefore == mins;
                  final label = mins == 0
                      ? localizations.get('at_time')
                      : '$mins ${localizations.get('min')}';
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _minutesBefore = mins),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Schedule type
              Text(
                localizations.get('schedule'),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ScheduleType>(
                segments: [
                  ButtonSegment(
                    value: ScheduleType.daily,
                    label: Text(localizations.get('daily')),
                    icon: const Icon(Icons.repeat, size: 18),
                  ),
                  ButtonSegment(
                    value: ScheduleType.weekdays,
                    label: Text(localizations.get('weekdays_label')),
                    icon: const Icon(Icons.calendar_view_week, size: 18),
                  ),
                  ButtonSegment(
                    value: ScheduleType.oneTime,
                    label: Text(localizations.get('one_time')),
                    icon: const Icon(Icons.event, size: 18),
                  ),
                ],
                selected: {_scheduleType},
                onSelectionChanged: (selected) {
                  setState(() => _scheduleType = selected.first);
                },
              ),
              const SizedBox(height: 12),

              // Weekday selector
              if (_scheduleType == ScheduleType.weekdays) ...[
                Wrap(
                  spacing: 4,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final isSelected = _selectedWeekdays.contains(day);
                    return FilterChip(
                      label: Text(
                          _getShortDayName(day, localizations)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWeekdays.add(day);
                          } else if (_selectedWeekdays.length > 1) {
                            _selectedWeekdays.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],

              // Date picker for one-time
              if (_scheduleType == ScheduleType.oneTime) ...[
                InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          _oneTimeDate != null
                              ? '${_oneTimeDate!.day}/${_oneTimeDate!.month}/${_oneTimeDate!.year}'
                              : localizations.get('select_date'),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSave() ? () => _save(context) : null,
                  icon: const Icon(Icons.notifications_active),
                  label: Text(localizations.get('save')),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortDayName(int weekday, AppLocalizations localizations) {
    final keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return localizations.get(keys[weekday - 1]);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _oneTimeDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _oneTimeDate = picked);
    }
  }

  bool _canSave() {
    if (_scheduleType == ScheduleType.oneTime && _oneTimeDate == null) {
      return false;
    }
    return true;
  }

  void _save(BuildContext context) {
    final provider = context.read<NotificationProvider>();
    final existing = widget.existingPreference;

    final pref = NotificationPreference(
      id: existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      zmanKey: _selectedZmanKey,
      zmanName: _selectedZmanName,
      minutesBefore: _minutesBefore,
      scheduleType: _scheduleType,
      selectedWeekdays: _selectedWeekdays,
      oneTimeDate: _oneTimeDate,
      enabled: existing?.enabled ?? true,
    );

    if (existing != null) {
      provider.updatePreference(pref);
    } else {
      provider.addPreference(pref);
    }

    Navigator.pop(context);
  }
}
