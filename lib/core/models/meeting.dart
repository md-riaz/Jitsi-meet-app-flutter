import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Meeting {
  final String id;
  final String roomName;
  final String? subject;
  final String? password;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String serverURL;
  final String? creatorName;
  final String? creatorEmail;
  final int? durationMinutes;

  const Meeting({
    required this.id,
    required this.roomName,
    this.subject,
    this.password,
    required this.createdAt,
    this.scheduledFor,
    this.serverURL = 'https://app.alorameet.com',
    this.creatorName,
    this.creatorEmail,
    this.durationMinutes,
  });

  factory Meeting.create({
    required String roomName,
    String? subject,
    String? password,
    DateTime? scheduledFor,
    String serverURL = 'https://app.alorameet.com',
    String? creatorName,
    String? creatorEmail,
  }) {
    return Meeting(
      id: _uuid.v4(),
      roomName: roomName,
      subject: subject,
      password: password,
      createdAt: DateTime.now(),
      scheduledFor: scheduledFor,
      serverURL: serverURL,
      creatorName: creatorName,
      creatorEmail: creatorEmail,
    );
  }

  Meeting copyWith({
    String? id,
    String? roomName,
    String? subject,
    String? password,
    DateTime? createdAt,
    DateTime? scheduledFor,
    String? serverURL,
    String? creatorName,
    String? creatorEmail,
    int? durationMinutes,
  }) {
    return Meeting(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      subject: subject ?? this.subject,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      serverURL: serverURL ?? this.serverURL,
      creatorName: creatorName ?? this.creatorName,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomName': roomName,
      'subject': subject,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'serverURL': serverURL,
      'creatorName': creatorName,
      'creatorEmail': creatorEmail,
      'durationMinutes': durationMinutes,
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String,
      roomName: json['roomName'] as String,
      subject: json['subject'] as String?,
      password: json['password'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      serverURL: json['serverURL'] as String? ?? 'https://app.alorameet.com',
      creatorName: json['creatorName'] as String?,
      creatorEmail: json['creatorEmail'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }
}
