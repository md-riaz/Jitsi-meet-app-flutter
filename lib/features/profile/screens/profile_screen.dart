import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/models/user_profile.dart';
import 'package:alora_meet/core/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<StorageService>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile?.displayName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _avatarController =
        TextEditingController(text: profile?.avatarURL ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    }
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    final storageService =
        Provider.of<StorageService>(context, listen: false);
    final current = storageService.profile;
    if (current == null) return;

    final updated = current.copyWith(
      displayName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : current.displayName,
      email: _emailController.text.trim(),
      avatarURL: _avatarController.text.trim().isNotEmpty
          ? _avatarController.text.trim()
          : null,
      lastActive: DateTime.now(),
    );

    storageService.updateProfile(updated);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton.icon(
            onPressed: _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.check_rounded : Icons.edit_outlined,
              size: 18,
            ),
            label: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: Consumer<StorageService>(
        builder: (context, storage, _) {
          final profile = storage.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_isEditing) {
            // Sync controllers when not editing
            _nameController.text = profile.displayName;
            _emailController.text = profile.email;
            _avatarController.text = profile.avatarURL ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              children: [
                _buildAvatar(profile, colorScheme, theme),
                const SizedBox(height: 32),
                _buildInfoSection(profile, theme, colorScheme),
                const SizedBox(height: 28),
                _buildStatsSection(profile, theme, colorScheme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(
      UserProfile profile, ColorScheme colorScheme, ThemeData theme) {
    final hasAvatar =
        profile.avatarURL != null && profile.avatarURL!.isNotEmpty;
    final initials = _getInitials(profile.displayName);

    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: colorScheme.primary.withAlpha(30),
          backgroundImage:
              hasAvatar ? NetworkImage(profile.avatarURL!) : null,
          child: hasAvatar
              ? null
              : Text(
                  initials,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        if (!_isEditing) ...[
          Text(
            profile.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(130),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildInfoSection(
      UserProfile profile, ThemeData theme, ColorScheme colorScheme) {
    if (!_isEditing) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildEditField(
            controller: _nameController,
            label: 'Display Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildEditField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildEditField(
            controller: _avatarController,
            label: 'Avatar URL',
            icon: Icons.image_outlined,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildStatsSection(
      UserProfile profile, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.videocam_rounded,
                  value: '${profile.totalMeetings}',
                  label: 'Meetings',
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_rounded,
                  value: _formatDuration(profile.totalMinutes),
                  label: 'Total Time',
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Member since',
            value: DateFormat('MMMM d, y').format(profile.createdAt),
            colorScheme: colorScheme,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Last active',
            value: _formatLastActive(profile.lastActive),
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final diff = now.difference(lastActive);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays == 0) return 'Today, ${DateFormat.jm().format(lastActive)}';
    if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat.jm().format(lastActive)}';
    }
    return DateFormat('MMM d, y · h:mm a').format(lastActive);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(130),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
