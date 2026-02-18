import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import '../models/app_settings.dart';
import '../models/meeting.dart';

class JitsiService {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  Future<void> joinMeeting({
    required Meeting meeting,
    required AppSettings settings,
    Function(String message)? onConferenceJoined,
    Function(String message)? onConferenceTerminated,
    Function(Map<String, dynamic> data)? onParticipantJoined,
    Function(Map<String, dynamic> data)? onParticipantLeft,
    Function(String error)? onError,
  }) async {
    try {
      final serverURL =
          meeting.serverURL.isNotEmpty ? meeting.serverURL : settings.serverURL;

      final Map<String, Object> featureFlags = {};
      for (final entry in settings.featureFlags.entries) {
        featureFlags[entry.key] = entry.value;
      }

      final Map<String, Object> configOverrides =
          Map<String, Object>.from(settings.configOverrides);
      configOverrides['startWithAudioMuted'] = settings.startWithAudioMuted;
      configOverrides['startWithVideoMuted'] = settings.startWithVideoMuted;
      if (meeting.subject != null && meeting.subject!.isNotEmpty) {
        configOverrides['subject'] = meeting.subject!;
      }

      final displayName = meeting.creatorName ?? settings.displayName;
      final email = meeting.creatorEmail ?? settings.email;

      final options = JitsiMeetConferenceOptions(
        serverURL: serverURL,
        room: meeting.roomName,
        configOverrides: configOverrides,
        featureFlags: featureFlags,
        userInfo: JitsiMeetUserInfo(
          displayName: displayName,
          email: email,
          avatar: settings.avatarURL,
        ),
      );

      final listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          onConferenceJoined?.call(url);
        },
        conferenceTerminated: (url, error) {
          onConferenceTerminated?.call(url);
        },
        participantJoined: (email, name, role, participantId) {
          onParticipantJoined?.call({
            'email': email,
            'name': name,
            'role': role,
            'id': participantId,
          });
        },
        participantLeft: (participantId) {
          onParticipantLeft?.call({'id': participantId});
        },
      );

      await _jitsiMeet.join(options, listener);
    } catch (e) {
      final errorMessage = 'Failed to join meeting: ${e.toString()}';
      onError?.call(errorMessage);
      rethrow;
    }
  }

  Future<void> hangUp() async {
    try {
      await _jitsiMeet.hangUp();
    } catch (e) {
      // Silently handle hangUp errors as user might already have left
    }
  }
}
