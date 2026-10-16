import 'package:flutter/material.dart';

import '../models/campus_booking.dart';
import '../theme.dart';
import '../widgets/campus_widgets.dart';

class BookingsScreen extends StatelessWidget {
  final List<CampusBooking> bookings;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final Future<void> Function(CampusBooking booking) onCancel;
  final VoidCallback onExplore;

  const BookingsScreen({
    super.key,
    required this.bookings,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onCancel,
    required this.onExplore,
  });

  Future<void> _confirmCancel(
    BuildContext context,
    CampusBooking booking,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text(
          'Cancel your reservation for ${booking.resource.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB33A45),
            ),
            child: const Text('Cancel reservation'),
          ),
        ],
      ),
    );
    if (shouldCancel == true) await onCancel(booking);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = bookings
        .where((booking) => booking.endsAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final past = bookings
        .where((booking) => !booking.endsAt.isAfter(now))
        .toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        const Text(
          'My bookings',
          style: TextStyle(
            color: navy,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your campus schedule, all in one place.',
          style: TextStyle(color: muted, fontSize: 13),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF183957), Color(0xFF087F83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reservations',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${upcoming.length} upcoming  ·  ${past.length} completed',
                      style: const TextStyle(
                        color: Color(0xFFDCEAF4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 36),
          const Center(child: CircularProgressIndicator()),
        ],
        if (!isLoading && errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Color(0xFF9B3037)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!isLoading && errorMessage == null) ...[
          const SizedBox(height: 23),
          const _BookingSectionTitle(title: 'Upcoming', icon: Icons.schedule_rounded),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            EmptyState(
              title: 'No upcoming reservations',
              subtitle: 'Find a space or resource and reserve a time that works.',
              action: FilledButton.icon(
                onPressed: onExplore,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find a resource'),
              ),
            )
          else
            ...upcoming.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _BookingCard(
                  booking: booking,
                  isUpcoming: true,
                  onCancel: booking.startsAt.isAfter(now)
                      ? () => _confirmCancel(context, booking)
                      : null,
                ),
              ),
            ),
          if (past.isNotEmpty) ...[
            const SizedBox(height: 15),
            const _BookingSectionTitle(
              title: 'Past reservations',
              icon: Icons.history_rounded,
            ),
            const SizedBox(height: 12),
            ...past.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _BookingCard(booking: booking, isUpcoming: false),
              ),
            ),
          ],
        ],
        const SizedBox(height: 12),
        const Text(
          'CampusHub demo reservations are saved locally on this device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _BookingSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _BookingSectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: teal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final CampusBooking booking;
  final bool isUpcoming;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    required this.isUpcoming,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = isUpcoming && !booking.startsAt.isAfter(DateTime.now());
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(booking.startsAt);
    final startTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(booking.startsAt),
    );
    final endTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(booking.endsAt),
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EDF4)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResourceIcon(icon: booking.resource.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.resource.name,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.resource.location,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _BookingTag(
                          icon: Icons.calendar_today_rounded,
                          label: date,
                        ),
                        _BookingTag(
                          icon: Icons.access_time_rounded,
                          label: '$startTime – $endTime',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming ? paleTeal : const Color(0xFFF0F3F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isInProgress
                      ? 'In progress'
                      : isUpcoming
                          ? 'Upcoming'
                          : 'Completed',
                  style: TextStyle(
                    color: isUpcoming ? teal : muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.event_busy_rounded, size: 17),
                label: const Text('Cancel reservation'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB33A45),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BookingTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: teal),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: navy, fontSize: 10)),
        ],
      ),
    );
  }
}
