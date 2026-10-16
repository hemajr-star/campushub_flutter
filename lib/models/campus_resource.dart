import 'package:flutter/material.dart';

final Map<String, IconData> _iconMap = {
  'meeting_room_rounded': Icons.meeting_room_rounded,
  'videocam_rounded': Icons.videocam_rounded,
  'menu_book_rounded': Icons.menu_book_rounded,
  'memory_rounded': Icons.memory_rounded,
  'school_rounded': Icons.school_rounded,
  'event_available_rounded': Icons.event_available_rounded,
};

class CampusResource {
  final String name;
  final String location;
  final IconData icon;
  final String type;
  final bool available;

  const CampusResource({
    required this.name,
    required this.location,
    required this.icon,
    required this.type,
    this.available = true,
  });

  factory CampusResource.fromJson(Map<String, dynamic> json) {
    final iconName = (json['icon'] as String?) ?? 'school_rounded';

    return CampusResource(
      name: json['name'] as String? ?? 'Unnamed resource',
      location: json['location'] as String? ?? 'Campus',
      icon: _iconMap[iconName] ?? Icons.school_rounded,
      type: json['type'] as String? ?? 'Venue',
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'type': type,
      'icon': _iconKey(icon),
      'available': available,
    };
  }

  static String _iconKey(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint &&
          entry.value.fontFamily == icon.fontFamily) {
        return entry.key;
      }
    }
    return 'school_rounded';
  }
}

const defaultResources = <CampusResource>[
  CampusResource(name: 'Seminar Hall A', location: 'Academic Block · Floor 2', icon: Icons.meeting_room_rounded, type: 'Venue'),
  CampusResource(name: 'Projector P-12', location: 'Library · Help Desk', icon: Icons.videocam_rounded, type: 'Equipment'),
  CampusResource(name: 'Study Room 03', location: 'Central Library · Floor 1', icon: Icons.menu_book_rounded, type: 'Study space'),
  CampusResource(name: 'Innovation Lab', location: 'Tech Block · Floor 3', icon: Icons.memory_rounded, type: 'Lab'),
];

List<CampusResource> resources = List<CampusResource>.from(defaultResources);
