# CampusHub – Campus Resource Booking

CampusHub is a Flutter campus resource app for discovering study spaces and equipment, reserving a time, and managing upcoming bookings.

## Included screens
- Student sign-in and profile creation screen with a campus welcome card
- Student dashboard with resource search and the next reservation
- Explore resources with search and category filters
- Reservation flow with date selection, one-hour time slots, and overlap checks
- Upcoming and completed bookings, including cancellation
- Student profile and QR scanning

## Run in VS Code (Windows)
1. Open the `campushub_flutter` folder in VS Code.
2. Open **Terminal → New Terminal**.
3. Run:
   ```bash
   flutter doctor
   flutter pub get
   flutter run
   ```
4. If asked to select a device, choose an Android emulator or connect an Android phone with USB debugging enabled. You can also run on Chrome with:
   ```bash
   flutter run -d chrome
   ```

## Demo data and authentication
- Student profiles and timed reservations are saved locally on the device/browser.
- The sign-in form is a demo flow. It validates the entered email and password format but does not verify student identity or authenticate against a server. Passwords are not stored.
- Resource listings can be loaded from the optional Node.js backend in `backend/`; otherwise the app uses its built-in sample resources.
- Reservations are local demo records, not shared with a campus booking system. Availability and conflict checks only cover reservations stored for the signed-in local profile.
- QR scanning requires camera permission and a supported camera/browser.
