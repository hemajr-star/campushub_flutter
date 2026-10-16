import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    required this.profile,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final initials = profile.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        const Text(
          'ACCOUNT',
          style: TextStyle(
            color: teal,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Your profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: paleTeal,
                child: Text(
                  initials.isEmpty ? 'S' : initials,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                profile.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
              if (profile.major.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: paleTeal,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    profile.major,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Student details',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        _ProfileDetail(
          icon: Icons.alternate_email_rounded,
          label: 'Student email',
          value: profile.email,
        ),
        if (profile.major.isNotEmpty)
          _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Program',
            value: profile.major,
          ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF5FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: navy, size: 19),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'This demo keeps your profile and reservations on this device. Your student identity is not verified.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onLogout != null) ...[
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9B3037),
              side: const BorderSide(color: Color(0xFFE8C9CB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: paleTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
