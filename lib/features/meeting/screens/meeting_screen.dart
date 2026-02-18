import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/meeting_service.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  String _formatElapsed(DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return 'N/A';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h hr';
    return '$h hr $m min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<MeetingService>(
      builder: (context, meetingService, _) {
        if (meetingService.isInMeeting) {
          return _buildActiveMeeting(
              context, theme, colorScheme, meetingService);
        }

        // Meeting ended — show summary if there's data, otherwise fallback
        if (meetingService.currentMeeting != null) {
          return _buildMeetingSummary(
              context, theme, colorScheme, meetingService);
        }

        return _buildNoMeeting(context, theme, colorScheme);
      },
    );
  }

  Widget _buildActiveMeeting(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, MeetingService meetingService) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Pulsing indicator
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(20),
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withAlpha(40),
                    ),
                    child: Icon(
                      Icons.videocam_rounded,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Meeting in Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                meetingService.currentRoomName ?? 'Unknown Room',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              // Meeting info cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.people_rounded,
                      label: 'Participants',
                      value: '${meetingService.participantCount}',
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    Divider(
                        color: colorScheme.onSurface.withAlpha(20), height: 1),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.timer_rounded,
                      label: 'Duration',
                      value: meetingService.meetingStartTime != null
                          ? _formatElapsed(meetingService.meetingStartTime!)
                          : 'Connecting...',
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    if (meetingService.currentMeeting?.subject != null &&
                        meetingService
                            .currentMeeting!.subject!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(
                          color: colorScheme.onSurface.withAlpha(20),
                          height: 1),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.subject_rounded,
                        label: 'Subject',
                        value: meetingService.currentMeeting!.subject!,
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Leave button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => meetingService.leaveMeeting(),
                  icon: const Icon(Icons.call_end_rounded),
                  label: const Text('Leave Meeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingSummary(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, MeetingService meetingService) {
    final meeting = meetingService.currentMeeting!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withAlpha(20),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Meeting Ended',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.meeting_room_rounded,
                      label: 'Room',
                      value: meeting.roomName,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                    if (meeting.subject != null &&
                        meeting.subject!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(
                          color: colorScheme.onSurface.withAlpha(20),
                          height: 1),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.subject_rounded,
                        label: 'Subject',
                        value: meeting.subject!,
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Divider(
                        color: colorScheme.onSurface.withAlpha(20), height: 1),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.timer_rounded,
                      label: 'Duration',
                      value: _formatDuration(meeting.durationMinutes),
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoMeeting(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_off_outlined,
                  size: 40,
                  color: colorScheme.primary.withAlpha(120),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No active meeting',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withAlpha(180),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join or create a meeting from the dashboard.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withAlpha(100),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(110),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
