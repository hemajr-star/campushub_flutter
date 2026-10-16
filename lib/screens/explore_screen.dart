import 'package:flutter/material.dart';
import '../models/campus_booking.dart';
import '../models/campus_resource.dart';
import '../services/campus_api.dart';
import '../theme.dart';
import '../utils/dialogs.dart';
import '../widgets/campus_widgets.dart';

class ExploreScreen extends StatefulWidget {
  final Future<bool> Function(
    CampusResource resource,
    DateTime startsAt,
    DateTime endsAt,
  ) onBook;
  final List<CampusBooking> bookings;

  const ExploreScreen({
    super.key,
    required this.onBook,
    this.bookings = const [],
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CampusApiService _api = CampusApiService();
  List<CampusResource> _resources = List<CampusResource>.from(defaultResources);
  String filter = 'All';
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
  Widget build(BuildContext context) {
    final list = _resources.where((r) {
      final matchesFilter = filter == 'All' || r.type == filter;
      final matchesQuery =
          '${r.name} ${r.location} ${r.type}'
              .toLowerCase()
              .contains(query.toLowerCase());

      return matchesFilter && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your next space',
                    style: TextStyle(
                      color: navy,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Spaces and equipment for your campus day.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: paleTeal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.apartment_rounded, color: teal, size: 18),
                  const SizedBox(width: 7),
                  Text(
                    '${list.length}',
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Search by name, type or location',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () => setState(() => query = ''),
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Venue', 'Equipment', 'Study space', 'Lab']
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: filter == category,
                      onSelected: (_) => setState(() => filter = category),
                      selectedColor: paleTeal,
                      showCheckmark: false,
                      side: BorderSide(
                        color: filter == category
                            ? const Color(0xFFB7E8DF)
                            : const Color(0xFFE5EBF0),
                      ),
                      labelStyle: TextStyle(
                        color: filter == category ? navy : muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Campus resources',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          '${list.length} ${list.length == 1 ? 'match' : 'matches'}',
          style: const TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 13),
        if (list.isEmpty)
          EmptyState(
            title: 'No resources found',
            subtitle: 'Try another search or switch the category filter.',
            action: TextButton.icon(
              onPressed: () => setState(() {
                filter = 'All';
                query = '';
              }),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear filters'),
            ),
          )
        else
          ...list.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResourceCard(
                resource: r,
                onView: () => showResourceDetails(
                  context,
                  r,
                  widget.bookings,
                  widget.onBook,
                ),
              ),
            ),
          ),
      ],
    );
  }
}