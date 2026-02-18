import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alora_meet/core/models/meeting.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/permission_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/shared/utils/dialog_utils.dart';

class CreateMeetingSheet extends StatefulWidget {
  const CreateMeetingSheet({super.key});

  @override
  State<CreateMeetingSheet> createState() => _CreateMeetingSheetState();
}

class _CreateMeetingSheetState extends State<CreateMeetingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _permissionService = PermissionService();
  bool _audioMuted = false;
  bool _videoMuted = false;

  @override
  void initState() {
    super.initState();
    final meetingService =
        Provider.of<MeetingService>(context, listen: false);
    final storage = Provider.of<StorageService>(context, listen: false);
    final settings = storage.settings;

    _roomController.text = meetingService.generateRoomName();
    _audioMuted = settings.startWithAudioMuted;
    _videoMuted = settings.startWithVideoMuted;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _meetingLink {
    final storage = Provider.of<StorageService>(context, listen: false);
    final serverURL = storage.settings.serverURL;
    return '$serverURL/${_roomController.text.trim()}';
  }

  void _shareMeetingLink() {
    final subject = _subjectController.text.trim().isNotEmpty
        ? _subjectController.text.trim()
        : 'Alora Meet';
    // ignore: deprecated_member_use
    Share.share('Join my meeting "$subject": $_meetingLink');
  }

  Future<void> _createAndJoin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Check and request permissions
      final permissionResult = await _permissionService.requestMeetingPermissions();
      
      if (!permissionResult.granted) {
        if (!mounted) return;
        
        final retry = await DialogUtils.showPermissionDeniedDialog(
          context,
          message: permissionResult.errorMessage,
          isPermanentlyDenied: permissionResult.permanentlyDenied,
        );
        
        // If user wants to retry (not permanently denied), try again
        if (retry == true && mounted) {
          await _createAndJoin();
        }
        return;
      }

      if (!mounted) return;

      final storageService = Provider.of<StorageService>(context, listen: false);
      final meetingService = Provider.of<MeetingService>(context, listen: false);

      final subject = _subjectController.text.trim().isNotEmpty
          ? _subjectController.text.trim()
          : 'Alora Meet';

      final settings = storageService.settings.copyWith(
        startWithAudioMuted: _audioMuted,
        startWithVideoMuted: _videoMuted,
      );

      final meeting = Meeting.create(
        roomName: _roomController.text.trim(),
        subject: subject,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        serverURL: storageService.settings.serverURL,
        creatorName: storageService.settings.displayName,
        creatorEmail: storageService.settings.email,
      );

      Navigator.pop(context);

      await meetingService.joinMeeting(
        meeting: meeting,
        settings: settings,
        storageService: storageService,
        onError: (error) {
          if (mounted) {
            DialogUtils.showErrorDialog(
              context,
              title: 'Failed to Create Meeting',
              message: 'Could not create the meeting. Please check your internet connection and try again.\n\nError: $error',
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      DialogUtils.showErrorDialog(
        context,
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
              // Title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_circle_rounded,
                        color: colorScheme.secondary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Create Meeting',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _shareMeetingLink,
                    tooltip: 'Share meeting link',
                    icon: Icon(Icons.share_outlined,
                        color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Subject
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject (optional)',
                  hintText: 'Alora Meet',
                  prefixIcon: Icon(Icons.subject_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              // Room name
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(
                  labelText: 'Room name',
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Generate new name',
                    onPressed: () {
                      final meetingService =
                          Provider.of<MeetingService>(context, listen: false);
                      setState(() {
                        _roomController.text =
                            meetingService.generateRoomName();
                      });
                    },
                  ),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Room name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  hintText: 'Secure your meeting',
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
              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createAndJoin,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create & Join'),
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
