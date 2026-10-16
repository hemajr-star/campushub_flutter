import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme.dart';

class StudentLoginScreen extends StatefulWidget {
  final Future<void> Function(UserProfile profile) onLogin;

  const StudentLoginScreen({super.key, required this.onLogin});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _majorController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _creatingAccount = false;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final studentName = _creatingAccount
        ? name
        : name.isNotEmpty
            ? name
            : _displayNameFromEmail(email);
    final profile = UserProfile(
      name: studentName,
      email: email,
      major: _majorController.text.trim().isEmpty
          ? 'Campus student'
          : _majorController.text.trim(),
    );

    setState(() => _submitting = true);
    try {
      await widget.onLogin(profile);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to continue: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _displayNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final words = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}');
    final name = words.join(' ');
    return name.isEmpty ? 'Campus student' : name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wideLayout ? 32 : 20,
                    vertical: wideLayout ? 24 : 20,
                  ),
                  children: [
                    const _BrandHeader(),
                    SizedBox(height: wideLayout ? 22 : 17),
                    if (wideLayout)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: _WelcomeCard()),
                          const SizedBox(width: 28),
                          Expanded(child: _buildLoginCard(context)),
                        ],
                      )
                    else ...[
                      const _WelcomeCard(compact: true),
                      const SizedBox(height: 20),
                      _buildLoginCard(context),
                      const SizedBox(height: 14),
                      _demoNotice(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF2)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _creatingAccount ? 'Create your account' : 'Welcome back',
            style: const TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _creatingAccount
                ? 'A few details and you’re ready to book.'
                : 'Sign in with your student email to continue.',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const SizedBox(height: 21),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_creatingAccount) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (_creatingAccount &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Enter your name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Student email',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                if (_creatingAccount) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _majorController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Major (optional)',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').length < 6) {
                      return 'Use at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 17),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _creatingAccount
                                ? 'Create student account'
                                : 'Sign in',
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Center(
            child: TextButton(
              onPressed: _submitting
                  ? null
                  : () => setState(() {
                        _creatingAccount = !_creatingAccount;
                      }),
              child: Text(
                _creatingAccount
                    ? 'Already registered? Sign in'
                    : 'New here? Create a student account',
              ),
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 850) ...[
            const SizedBox(height: 5),
            _demoNotice(),
          ],
        ],
      ),
    );
  }

  Widget _demoNotice() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 16, color: muted),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Demo sign-in: your profile and bookings stay on this device. Passwords are not stored and student identity is not verified.',
            style: TextStyle(color: muted, fontSize: 11, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: paleTeal,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.hub_rounded, color: teal),
        ),
        const SizedBox(width: 10),
        const Text(
          'CampusHub',
          style: TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final bool compact;

  const _WelcomeCard({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 25.0 : 36.0;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(compact ? 21 : 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183957), Color(0xFF087F83)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -26,
            child: Icon(
              Icons.account_balance_rounded,
              size: compact ? 100 : 180,
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YOUR CAMPUS, CONNECTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: compact ? 15 : 24),
              Text(
                compact
                    ? 'Find your space.\nMake it count.'
                    : 'Find your space.\nMake it count.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Discover campus spaces and book the time you need — all in one place.',
                style: TextStyle(
                  color: const Color(0xFFE1EEF1),
                  fontSize: compact ? 12 : 15,
                  height: 1.55,
                ),
              ),
              SizedBox(height: compact ? 15 : 28),
              Wrap(
                spacing: compact ? 15 : 22,
                runSpacing: 10,
                children: const [
                  _SplashBenefit(
                    icon: Icons.search_rounded,
                    label: 'Discover',
                  ),
                  _SplashBenefit(
                    icon: Icons.event_available_rounded,
                    label: 'Reserve',
                  ),
                  _SplashBenefit(
                    icon: Icons.bookmark_added_rounded,
                    label: 'Manage',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplashBenefit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SplashBenefit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9FE7D8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
