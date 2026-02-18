import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? avatarURL;
  final DateTime createdAt;
  final DateTime lastActive;
  final int totalMeetings;
  final int totalMinutes;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.email = '',
    this.avatarURL,
    required this.createdAt,
    required this.lastActive,
    this.totalMeetings = 0,
    this.totalMinutes = 0,
  });

  factory UserProfile.create({
    String displayName = 'Alora User',
    String email = '',
    String? avatarURL,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: _uuid.v4(),
      displayName: displayName,
      email: email,
      avatarURL: avatarURL,
      createdAt: now,
      lastActive: now,
    );
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarURL,
    DateTime? createdAt,
    DateTime? lastActive,
    int? totalMeetings,
    int? totalMinutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarURL: avatarURL ?? this.avatarURL,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      totalMeetings: totalMeetings ?? this.totalMeetings,
      totalMinutes: totalMinutes ?? this.totalMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'avatarURL': avatarURL,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'totalMeetings': totalMeetings,
      'totalMinutes': totalMinutes,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String? ?? '',
      avatarURL: json['avatarURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
      totalMeetings: json['totalMeetings'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
    );
  }
}
