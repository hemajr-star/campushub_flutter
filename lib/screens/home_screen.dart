import 'package:flutter/material.dart';
import '../models/campus_booking.dart';
import '../models/campus_resource.dart';
import '../services/campus_api.dart';
import '../theme.dart';
import '../utils/dialogs.dart';
import '../widgets/campus_widgets.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  final Future<bool> Function(
    CampusResource resource,
    DateTime startsAt,
    DateTime endsAt,
  ) onBook;
  final List<CampusBooking> bookings;
  final String userName;
  final VoidCallback? onOpenScanner;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onBook,
    this.bookings = const [],
    this.userName = 'Student Name',
    this.onOpenScanner,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  final CampusApiService _api = CampusApiService();
  List<CampusResource> _resources = List<CampusResource>.from(defaultResources);
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final loadedResources = await _api.fetchResources();
    if (mounted) {
      setState(() {
        _resources = loadedResources;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showShareDialog() {
    final api = CampusApiService();
    showShareDialog(
      context,
      onSubmit: (name, location) async {
        final success = await api.shareResource(name: name, location: location);
        if (!success) {
          final resource = CampusResource(
            name: name,
            location: location.isEmpty ? 'Campus' : location,
            type: 'Shared resource',
            icon: Icons.ios_share_rounded,
          );
          _resources = [resource, ..._resources];
          if (mounted) setState(() {});
        }
        return success;
      },
    );
  }

  void _showInfo(String title, String message) => showInfo(context, title, message);

  void _showResourceDetails(CampusResource resource) {
    showResourceDetails(context, resource, widget.bookings, widget.onBook);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final visibleResources = _resources
        .where(
          (resource) =>
              resource.name.toLowerCase().contains(normalizedQuery) ||
              resource.location.toLowerCase().contains(normalizedQuery) ||
              resource.type.toLowerCase().contains(normalizedQuery),
        )
        .take(3)
        .toList();
    final upcomingBookings = widget.bookings
        .where((booking) => booking.endsAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final firstName = widget.userName.trim().split(RegExp(r'\s+')).first;
    final initials = widget.userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Welcome, $firstName',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View bookings',
              onPressed: () => widget.onNavigate(2),
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
              style: IconButton.styleFrom(
                foregroundColor: navy,
                backgroundColor: Colors.white,
                fixedSize: const Size(48, 48),
                side: const BorderSide(color: borderColor),
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: paleTeal,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => widget.onNavigate(3),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Text(
                      initials.isEmpty ? 'S' : initials,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: searchController,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'What resource are you looking for?',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      setState(() => query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF17385B), Color(0xFF087F83)],
            ),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                top: -18,
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'YOUR CAMPUS, CONNECTED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Make room for\ngreat ideas.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find a space, reserve your time, and get to work.',
                    style: TextStyle(
                      color: Color(0xFFE1EEF1),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => widget.onNavigate(1),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('Explore resources'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeading(
          title: 'Quick actions',
          subtitle: 'Your campus essentials, one tap away',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 4 ? 2.05 : 1.75,
              children: [
                ActionCard(
                  title: 'Book resource',
                  icon: Icons.add_circle_outline_rounded,
                  color: teal,
                  onTap: () => widget.onNavigate(1),
                ),
                ActionCard(
                  title: 'Share resource',
                  icon: Icons.ios_share_rounded,
                  color: const Color(0xFF6B61C8),
                  onTap: _showShareDialog,
                ),
                ActionCard(
                  title: 'My bookings',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFFDA8B35),
                  onTap: () => widget.onNavigate(2),
                ),
                ActionCard(
                  title: 'Scan QR',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF278A68),
                  onTap: widget.onOpenScanner ??
                      () => _showInfo(
                        'Scan QR',
                        'QR scanning is available when a camera is connected.',
                      ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        SectionHeading(
          title: query.isEmpty ? 'Explore resources' : 'Search results',
          subtitle: '${visibleResources.length} resources to explore',
          trailing: TextButton(
            onPressed: () => widget.onNavigate(1),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: 12),
        if (visibleResources.isEmpty)
          const EmptyState(
            title: 'No resources found',
            subtitle: 'Try another name, type or location.',
          )
        else
          ...visibleResources.map(
            (resource) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: ResourceCard(
                resource: resource,
                onView: () => _showResourceDetails(resource),
              ),
            ),
          ),
        const SizedBox(height: 18),
        const SectionHeading(
          title: 'Your next booking',
          subtitle: 'A quick look at what’s coming up',
        ),
        const SizedBox(height: 12),
        _UpcomingBookingCard(
          booking: upcomingBookings.isEmpty ? null : upcomingBookings.first,
          onViewBookings: () => widget.onNavigate(2),
        ),
      ],
    );
  }
}

class _UpcomingBookingCard extends StatelessWidget {
  final CampusBooking? booking;
  final VoidCallback onViewBookings;

  const _UpcomingBookingCard({
    required this.booking,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    final nextBooking = booking;
    if (nextBooking == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE7EDF4)),
        ),
        child: Row(
          children: [
            const ResourceIcon(icon: Icons.event_note_rounded),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nothing on your calendar',
                    style: TextStyle(color: navy, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Book a campus space when you need one.',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onViewBookings,
              tooltip: 'View bookings',
              icon: const Icon(Icons.arrow_forward_rounded, color: teal),
            ),
          ],
        ),
      );
    }

    final date = MaterialLocalizations.of(context).formatMediumDate(
      nextBooking.startsAt,
    );
    final startTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(nextBooking.startsAt),
    );
    final endTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(nextBooking.endsAt),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onViewBookings,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE7EDF4)),
          ),
          child: Row(
            children: [
              const ResourceIcon(icon: Icons.event_available_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextBooking.resource.name,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date · $startTime – $endTime',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
