import 'dart:convert';

import 'package:campushub/app.dart';
import 'package:campushub/models/user_profile.dart';
import 'package:campushub/screens/auth_screen.dart';
import 'package:campushub/screens/student_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CampusHub opens to student sign in', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CampusHubApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Find your space.\nMake it count.'), findsOneWidget);
  });

  testWidgets('previous demo auto-login asks the student to sign in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'campushub_logged_in': true,
      'campushub_profile': jsonEncode({
        'name': 'Student Name',
        'email': 'student@campus.edu',
        'major': 'Computer Science',
      }),
    });

    await tester.pumpWidget(const CampusHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('student can sign in with a university email', (
    WidgetTester tester,
  ) async {
    var signedInEmail = '';
    await tester.pumpWidget(
      MaterialApp(
        home: StudentLoginScreen(
          onLogin: (profile) async {
            signedInEmail = profile.email;
          },
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Student email'),
      'alex.lee@campus.edu',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'student123',
    );
    await tester.ensureVisible(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(signedInEmail, 'alex.lee@campus.edu');
  });

  testWidgets('main navigation adapts cleanly to mobile and desktop', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      const MaterialApp(
        home: MainShell(
          userProfile: UserProfile(
            name: 'Alex Lee',
            email: 'alex.lee@campus.edu',
            major: 'Computer Science',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();
    expect(find.text('Find your next space'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}
