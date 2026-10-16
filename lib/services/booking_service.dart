import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/campus_booking.dart';
import '../models/campus_resource.dart';

class BookingService {
  String _storageKey(String studentEmail) =>
      'campushub_bookings_${studentEmail.trim().toLowerCase()}';

  Future<List<CampusBooking>> getBookings(String studentEmail) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_storageKey(studentEmail));
    if (stored == null || stored.isEmpty) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;
    final bookings = decoded
        .map(
          (item) => CampusBooking.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    bookings.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return bookings;
  }

  Future<CampusBooking> createBooking({
    required String studentEmail,
    required CampusResource resource,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    if (!resource.available) {
      throw StateError('This resource is currently unavailable.');
    }
    if (!startsAt.isBefore(endsAt) || startsAt.isBefore(DateTime.now())) {
      throw StateError('Choose a valid future time for your reservation.');
    }

    final bookings = await getBookings(studentEmail);
    final overlaps = bookings.any(
      (booking) =>
          booking.resource.name == resource.name &&
          startsAt.isBefore(booking.endsAt) &&
          booking.startsAt.isBefore(endsAt),
    );
    if (overlaps) {
      throw StateError('You already have a booking for this resource at that time.');
    }

    final booking = CampusBooking(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      resource: resource,
      startsAt: startsAt,
      endsAt: endsAt,
    );
    bookings.add(booking);
    bookings.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey(studentEmail),
      jsonEncode(bookings.map((item) => item.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Your reservation could not be saved on this device.');
    }
    return booking;
  }

  Future<void> cancelBooking({
    required String studentEmail,
    required String bookingId,
  }) async {
    final bookings = await getBookings(studentEmail);
    final remaining = bookings.where((booking) => booking.id != bookingId).toList();
    if (remaining.length == bookings.length) {
      throw StateError('This reservation could not be found.');
    }

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey(studentEmail),
      jsonEncode(remaining.map((item) => item.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Your reservation could not be cancelled.');
    }
  }
}
