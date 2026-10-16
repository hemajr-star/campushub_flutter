class UserProfile {
  final String name;
  final String email;
  final String major;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const UserProfile({
    required this.name,
    required this.email,
    required this.major,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Student Name',
      email: json['email'] as String? ?? 'student@campus.edu',
      major: json['major'] as String? ?? 'Computer Science',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'major': major,
        'notificationsEnabled': notificationsEnabled,
        'darkModeEnabled': darkModeEnabled,
      };

  UserProfile copyWith({
    String? name,
    String? email,
    String? major,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      major: major ?? this.major,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}
