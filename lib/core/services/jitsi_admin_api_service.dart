import '../models/meeting.dart';
import 'api_client.dart';

class JitsiAdminApiService {
  final ApiClient _client;

  JitsiAdminApiService(this._client);

  Future<String> login({
    required String email,
    required String password,
    String deviceName = 'flutter-app',
  }) async {
    final payload = await _client.postJson('/auth/login', {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });

    return payload['data']?['token']?.toString() ?? '';
  }

  Future<Meeting> joinByMeetingId({
    required String meetingId,
    String? password,
    String? inviteToken,
  }) async {
    final payload = await _client.postJson('/meetings/$meetingId/join', {
      if (password != null && password.isNotEmpty) 'password': password,
      if (inviteToken != null && inviteToken.isNotEmpty) 'invite_token': inviteToken,
    });

    final data = payload['data'] as Map<String, dynamic>;
    final jitsi = (data['jitsi'] as Map<String, dynamic>? ?? const {});

    return Meeting.create(
      roomName: (jitsi['room_name'] ?? '').toString(),
      serverURL: 'https://${(jitsi['domain'] ?? '').toString()}',
      creatorName: jitsi['display_name']?.toString(),
      creatorEmail: '',
      jwt: jitsi['jwt']?.toString(),
      sourceMeetingId: meetingId,
    );
  }

  Future<Meeting> joinGuestByMeetingId({
    required String meetingId,
    String? inviteToken,
    String? displayName,
    String? email,
  }) async {
    final payload = await _client.postJson('/meetings/$meetingId/join-guest', {
      if (inviteToken != null && inviteToken.isNotEmpty) 'invite_token': inviteToken,
      if (displayName != null && displayName.isNotEmpty) 'display_name': displayName,
      if (email != null && email.isNotEmpty) 'email': email,
    });

    final data = payload['data'] as Map<String, dynamic>;
    final jitsi = (data['jitsi'] as Map<String, dynamic>? ?? const {});

    return Meeting.create(
      roomName: (jitsi['room_name'] ?? '').toString(),
      serverURL: 'https://${(jitsi['domain'] ?? '').toString()}',
      creatorName: jitsi['display_name']?.toString(),
      creatorEmail: email,
      jwt: jitsi['jwt']?.toString(),
      sourceMeetingId: meetingId,
    );
  }

  Future<void> resolveInviteToken(String token) async {
    await _client.postJson('/invites/resolve', {'token': token});
  }

  Future<void> acceptInviteToken({
    required String token,
    String? name,
    String? email,
  }) async {
    await _client.postJson('/invites/$token/accept', {
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
    });
  }

  Future<String> getAdmissionStatus({
    required String meetingId,
    required String participantId,
  }) async {
    final payload = await _client.getJson('/meetings/$meetingId/admission-status?participant_id=$participantId');
    return (payload['data']?['status'] ?? '').toString();
  }
}

