import 'package:flutter/material.dart';

import '../models/campus_booking.dart';
import '../models/campus_resource.dart';
import '../theme.dart';
import '../widgets/campus_widgets.dart';

void showResourceDetails(
  BuildContext context,
  CampusResource resource,
  List<CampusBooking> bookings,
  Future<bool> Function(
    CampusResource resource,
    DateTime startsAt,
    DateTime endsAt,
  ) onBook,
) {
  var selectedDate = DateUtils.dateOnly(DateTime.now());
  int? selectedHour;

  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        final availableHours = resource.available
            ? _availableHours(resource, selectedDate, bookings)
            : <int>[];
        final selectedTime = availableHours.contains(selectedHour)
            ? selectedHour
            : (availableHours.isEmpty ? null : availableHours.first);
        final navigator = Navigator.of(sheetContext);
        final dateLabel = MaterialLocalizations.of(sheetContext)
            .formatMediumDate(selectedDate);

        return Container(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            22 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ResourceIcon(icon: resource.icon),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.name,
                              style: const TextStyle(
                                color: navy,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              resource.location,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose your reservation time',
                    style: TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final today = DateUtils.dateOnly(DateTime.now());
                      final pickedDate = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDate,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setSheetState(() => selectedDate = pickedDate);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(dateLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey(selectedTime),
                    initialValue: selectedTime,
                    decoration: const InputDecoration(
                      labelText: 'Start time · 1 hour',
                      prefixIcon: Icon(Icons.access_time_rounded),
                    ),
                    items: availableHours
                        .map(
                          (hour) => DropdownMenuItem(
                            value: hour,
                            child: Text(
                              MaterialLocalizations.of(sheetContext)
                                  .formatTimeOfDay(TimeOfDay(hour: hour, minute: 0)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: availableHours.isEmpty
                        ? null
                        : (hour) => setSheetState(() => selectedHour = hour),
                  ),
                  if (availableHours.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      resource.available
                          ? 'No one-hour slots are available on this date. Try another day.'
                          : 'This resource is currently unavailable. Try another resource.',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selectedTime == null || !resource.available
                          ? null
                          : () async {
                              final start = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime,
                              );
                              final booked = await onBook(
                                resource,
                                start,
                                start.add(const Duration(hours: 1)),
                              );
                              if (booked && navigator.mounted) {
                                navigator.pop();
                              }
                            },
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text('Confirm reservation'),
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

List<int> _availableHours(
  CampusResource resource,
  DateTime date,
  List<CampusBooking> bookings,
) {
  return [
    for (var hour = 8; hour < 20; hour++)
      if (DateTime(date.year, date.month, date.day, hour)
              .isAfter(DateTime.now()) &&
          !bookings.any(
            (booking) =>
                booking.resource.name == resource.name &&
                DateTime(date.year, date.month, date.day, hour)
                    .isBefore(booking.endsAt) &&
                booking.startsAt.isBefore(
                  DateTime(date.year, date.month, date.day, hour + 1),
                ),
          ))
        hour,
  ];
}


void showInfo(BuildContext context, String title, String message) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
  ));
}


void showShareDialog(
  BuildContext context, {
  Future<bool> Function(String name, String location)? onSubmit,
}) {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final messenger = ScaffoldMessenger.maybeOf(context);
  var isSubmitting = false;

  showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final navigator = Navigator.of(dialogContext, rootNavigator: true);

        return AlertDialog(
          title: const Text('Share a Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Resource name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final location = locationController.text.trim();

                      if (name.isEmpty) {
                        messenger?.showSnackBar(
                          const SnackBar(content: Text('Please enter a resource name.')),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final submitted = await (onSubmit?.call(name, location) ??
                                Future.value(true));

                        if (navigator.mounted) {
                          navigator.pop();
                        }

                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text(
                              submitted
                                  ? 'Share request for $name submitted successfully.'
                                  : 'Share request saved locally.',
                            ),
                          ),
                        );
                      } catch (_) {
                        messenger?.showSnackBar(
                          const SnackBar(content: Text('Unable to submit share request.')),
                        );
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: Text(isSubmitting ? 'Submitting...' : 'Submit'),
            ),
          ],
        );
      },
    ),
  );
}
