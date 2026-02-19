import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/app/routes.dart';
import 'package:alora_meet/core/models/meeting.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/permission_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/shared/utils/dialog_utils.dart';

class JoinMeetingSheet extends StatefulWidget {
  const JoinMeetingSheet({super.key});

  @override
  State<JoinMeetingSheet> createState() => _JoinMeetingSheetState();
}

class _JoinMeetingSheetState extends State<JoinMeetingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _permissionService = PermissionService();
  bool _audioMuted = false;
  bool _videoMuted = false;
  int _permissionRetryCount = 0;
  static const int _maxPermissionRetries = 2;

  @override
  void initState() {
    super.initState();
    final storage = Provider.of<StorageService>(context, listen: false);
    final settings = storage.settings;
    _nameController.text = settings.displayName;
    _audioMuted = settings.startWithAudioMuted;
    _videoMuted = settings.startWithVideoMuted;
  }

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Extracts room name from a full Jitsi URL or returns input as-is.
  String _extractRoomName(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return trimmed;
  }

  Future<void> _joinMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Check and request permissions
      final permissionResult = await _permissionService.requestMeetingPermissions();
      
      if (!permissionResult.granted) {
        if (!mounted) return;
        
        _permissionRetryCount++;
        
        final retry = await DialogUtils.showPermissionDeniedDialog(
          context,
          message: permissionResult.errorMessage,
          isPermanentlyDenied: permissionResult.permanentlyDenied,
        );
        
        // If user wants to retry and haven't exceeded max retries, try again
        if (retry == true && _permissionRetryCount < _maxPermissionRetries && mounted) {
          await _joinMeeting();
        } else if (_permissionRetryCount >= _maxPermissionRetries && mounted) {
          // Show a different message after max retries
          DialogUtils.showErrorDialog(
            context,
            title: 'Permissions Required',
            message: 'Camera and microphone permissions are required to join meetings. Please enable them in device settings.',
          );
        }
        return;
      }

      if (!mounted) return;

      final storageService = Provider.of<StorageService>(context, listen: false);
      final meetingService = Provider.of<MeetingService>(context, listen: false);

      final roomName = _extractRoomName(_roomController.text);
      final settings = storageService.settings.copyWith(
        displayName: _nameController.text.trim(),
        startWithAudioMuted: _audioMuted,
        startWithVideoMuted: _videoMuted,
      );

      final meeting = Meeting.create(
        roomName: roomName,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        serverURL: storageService.settings.serverURL,
        creatorName: _nameController.text.trim(),
        creatorEmail: storageService.settings.email,
      );

      final navigator = Navigator.of(context);
      final dialogContext = navigator.context;

      // Start the join first so MeetingScreen sees active state immediately.
      final joinFuture = meetingService.joinMeeting(
        meeting: meeting,
        settings: settings,
        storageService: storageService,
        onError: (error) {
          if (navigator.mounted) {
            DialogUtils.showErrorDialog(
              dialogContext,
              title: 'Failed to Join Meeting',
              message: 'Could not join the meeting. Please check your internet connection and try again.\n\nError: $error',
            );
          }
        },
      );

      // Close the bottom sheet
      navigator.pop();

      // Navigate to meeting screen without waiting for it to pop.
      if (navigator.mounted) {
        navigator.pushNamed(AppRoutes.meeting);
      }

      // Await join so errors propagate to catch.
      await joinFuture;
    } catch (e) {
      final navigator = Navigator.of(context);
      if (!navigator.mounted) return;

      DialogUtils.showErrorDialog(
        navigator.context,
        title: 'Error',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.videocam_rounded,
                        color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Join Meeting',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Room name
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room name or link',
                  hintText: 'e.g. my-meeting or https://meet.jit.si/room',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a room name or link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Display name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  hintText: 'Your name in the meeting',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  hintText: 'Meeting password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              // Toggles
              _ToggleRow(
                icon: Icons.mic_off_outlined,
                label: 'Start with audio muted',
                value: _audioMuted,
                onChanged: (v) => setState(() => _audioMuted = v),
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                icon: Icons.videocam_off_outlined,
                label: 'Start with video muted',
                value: _videoMuted,
                onChanged: (v) => setState(() => _videoMuted = v),
              ),
              const SizedBox(height: 28),
              // Join button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _joinMeeting,
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Join Meeting'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withAlpha(160)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(200),
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
