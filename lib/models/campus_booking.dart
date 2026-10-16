import 'campus_resource.dart';

class CampusBooking {
  final String id;
  final CampusResource resource;
  final DateTime startsAt;
  final DateTime endsAt;

  const CampusBooking({
    required this.id,
    required this.resource,
    required this.startsAt,
    required this.endsAt,
  });

  factory CampusBooking.fromJson(Map<String, dynamic> json) {
    return CampusBooking(
      id: json['id'] as String,
      resource: CampusResource.fromJson(
        Map<String, dynamic>.from(json['resource'] as Map),
      ),
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'resource': resource.toJson(),
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
      };
}
