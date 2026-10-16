import 'package:campushub/models/campus_resource.dart';
import 'package:campushub/services/booking_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late BookingService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = BookingService();
  });

  test('reservations persist separately for each student', () async {
    final start = DateTime.now().add(const Duration(days: 1));
    await service.createBooking(
      studentEmail: 'one@campus.edu',
      resource: defaultResources.first,
      startsAt: start,
      endsAt: start.add(const Duration(hours: 1)),
    );

    expect(await service.getBookings('one@campus.edu'), hasLength(1));
    expect(await service.getBookings('two@campus.edu'), isEmpty);
  });

  test('overlapping reservations for the same resource are rejected', () async {
    final start = DateTime.now().add(const Duration(days: 1));
    await service.createBooking(
      studentEmail: 'one@campus.edu',
      resource: defaultResources.first,
      startsAt: start,
      endsAt: start.add(const Duration(hours: 1)),
    );

    expect(
      () => service.createBooking(
        studentEmail: 'one@campus.edu',
        resource: defaultResources.first,
        startsAt: start.add(const Duration(minutes: 30)),
        endsAt: start.add(const Duration(hours: 2)),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('a reservation can be cancelled', () async {
    final start = DateTime.now().add(const Duration(days: 1));
    final booking = await service.createBooking(
      studentEmail: 'one@campus.edu',
      resource: defaultResources.first,
      startsAt: start,
      endsAt: start.add(const Duration(hours: 1)),
    );

    await service.cancelBooking(
      studentEmail: 'one@campus.edu',
      bookingId: booking.id,
    );

    expect(await service.getBookings('one@campus.edu'), isEmpty);
  });
}
