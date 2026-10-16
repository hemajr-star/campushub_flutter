import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AuthService {
  static const String _profileKey = 'campushub_profile';
  static const String _loggedInKey = 'campushub_logged_in';
  static const String _authVersionKey = 'campushub_auth_version';
  static const int _currentAuthVersion = 2;

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) == true &&
        prefs.getInt(_authVersionKey) == _currentAuthVersion;
  }

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_profileKey);
    if (rawProfile == null || rawProfile.isEmpty) {
      return null;
    }

    final profileMap = jsonDecode(rawProfile) as Map<String, dynamic>;
    return UserProfile.fromJson(profileMap);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    await prefs.setInt(_authVersionKey, _currentAuthVersion);
    await prefs.setBool(_loggedInKey, true);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }
}
