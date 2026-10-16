import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/campus_resource.dart';

class CampusApiService {
  static const String _baseUrl = 'http://127.0.0.1:3000';

  Future<List<CampusResource>> fetchResources() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/resources')).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final items = decoded['resources'] as List<dynamic>? ?? const [];
        return items
            .map((item) => CampusResource.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      // Fallback to the demo resource list when the backend is unavailable.
    }

    return List<CampusResource>.from(resources);
  }

  Future<List<CampusResource>> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/bookings')).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final items = decoded['bookings'] as List<dynamic>? ?? const [];
        return items
            .map((item) => CampusResource.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {
      // Ignore backend failures and fall back to the in-memory demo data.
    }

    return List<CampusResource>.from(resources.where((resource) => resource.name == 'Study Room 03'));
  }

  Future<CampusResource> createBooking(CampusResource resource) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(resource.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final booking = decoded['booking'];
        if (booking != null) {
          return CampusResource.fromJson(Map<String, dynamic>.from(booking as Map));
        }
      }
    } catch (_) {
      // Keep the local app working even if the backend is offline.
    }

    return resource;
  }

  Future<bool> shareResource({required String name, String? location}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/resources/share'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'location': location ?? 'Campus',
          'type': 'Shared resource',
          'available': true,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
