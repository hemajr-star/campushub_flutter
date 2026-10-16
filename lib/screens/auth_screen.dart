import 'package:flutter/material.dart';

import '../models/campus_booking.dart';
import '../models/campus_resource.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../theme.dart';
import 'bookings_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'student_login_screen.dart';

class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final profile = isLoggedIn ? await _authService.getProfile() : null;
    if (!mounted) return;

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin(UserProfile profile) async {
    final savedProfile = await _authService.getProfile();
    final activeProfile =
        savedProfile?.email.toLowerCase() == profile.email.toLowerCase()
            ? savedProfile!
            : profile;
    await _authService.saveProfile(activeProfile);
    if (!mounted) return;
    setState(() => _profile = activeProfile);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile;
    if (profile != null) return MainShell(userProfile: profile);
    return StudentLoginScreen(onLogin: _handleLogin);
  }
}

class MainShell extends StatefulWidget {
  final UserProfile userProfile;

  const MainShell({super.key, required this.userProfile});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final UserProfile _profile = widget.userProfile;
  final BookingService _bookingService = BookingService();
  List<CampusBooking> _bookings = [];
  bool _bookingsLoading = true;
  String? _bookingsError;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (mounted) {
      setState(() {
        _bookingsLoading = true;
        _bookingsError = null;
      });
    }
    try {
      final bookings = await _bookingService.getBookings(_profile.email);
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _bookingsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bookingsLoading = false;
        _bookingsError = 'Could not load reservations: $error';
      });
    }
  }

  void _goTo(int index) => setState(() => _selectedIndex = index);

  Future<bool> _bookResource(
    CampusResource resource,
    DateTime startsAt,
    DateTime endsAt,
  ) async {
    try {
      final booking = await _bookingService.createBooking(
        studentEmail: _profile.email,
        resource: resource,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      if (!mounted) return false;
      setState(() {
        _bookings = [..._bookings, booking]
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${resource.name} reserved successfully.')),
      );
      return true;
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
      return false;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create reservation: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _cancelBooking(CampusBooking booking) async {
    try {
      await _bookingService.cancelBooking(
        studentEmail: _profile.email,
        bookingId: booking.id,
      );
      if (!mounted) return;
      setState(() {
        _bookings.removeWhere((item) => item.id == booking.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${booking.resource.name} reservation cancelled.'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not cancel reservation: $error')),
        );
      }
    }
  }

  Future<void> _openScanner() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted) return;
    if (result != null && messenger != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('QR code scanned: $result')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGateway()),
        (route) => false,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not sign out: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onNavigate: _goTo,
        onBook: _bookResource,
        bookings: _bookings,
        userName: _profile.name,
        onOpenScanner: _openScanner,
      ),
      ExploreScreen(onBook: _bookResource, bookings: _bookings),
      BookingsScreen(
        bookings: _bookings,
        isLoading: _bookingsLoading,
        errorMessage: _bookingsError,
        onRetry: _loadBookings,
        onCancel: _cancelBooking,
        onExplore: () => _goTo(1),
      ),
      ProfileScreen(profile: _profile, onLogout: _logout),
    ];

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore_rounded),
        label: 'Explore',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded),
        label: 'Bookings',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _goTo,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: pageBg,
                        indicatorColor: paleTeal,
                        destinations: destinations
                            .map(
                              (destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(destination.label),
                              ),
                            )
                            .toList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: IndexedStack(
                              index: _selectedIndex,
                              children: pages,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 900
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _goTo,
              destinations: destinations,
            )
          : null,
    );
  }
}
