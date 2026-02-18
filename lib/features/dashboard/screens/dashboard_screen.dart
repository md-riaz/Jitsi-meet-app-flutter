import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/app/routes.dart';
import 'package:alora_meet/core/models/meeting.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/features/dashboard/widgets/create_meeting_sheet.dart';
import 'package:alora_meet/features/dashboard/widgets/join_meeting_sheet.dart';
import 'package:alora_meet/features/dashboard/widgets/meeting_history_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        setState(() => _currentIndex = 0);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.history);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
  }

  void _showJoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const JoinMeetingSheet(),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateMeetingSheet(),
    );
  }

  void _rejoinMeeting(Meeting meeting) {
    final storageService =
        Provider.of<StorageService>(context, listen: false);
    final meetingService =
        Provider.of<MeetingService>(context, listen: false);
    final settings = storageService.settings;

    final newMeeting = Meeting.create(
      roomName: meeting.roomName,
      subject: meeting.subject,
      password: meeting.password,
      serverURL: meeting.serverURL,
      creatorName: settings.displayName,
      creatorEmail: settings.email,
    );

    meetingService.joinMeeting(
      meeting: newMeeting,
      settings: settings,
      storageService: storageService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, color: colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text('Alora Meet'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<StorageService>(
              builder: (context, storage, _) {
                final name = storage.settings.displayName;
                return GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.profile),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primary.withAlpha(40),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(theme, colorScheme),
              const SizedBox(height: 28),
              _buildQuickActions(theme, colorScheme),
              const SizedBox(height: 32),
              _buildRecentMeetings(theme, colorScheme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(ThemeData theme, ColorScheme colorScheme) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, y').format(now);

    return Consumer<StorageService>(
      builder: (context, storage, _) {
        final name = storage.settings.displayName;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_greeting,',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha(160),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(130),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.videocam_rounded,
                label: 'Join\nMeeting',
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: _showJoinSheet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_rounded,
                label: 'Create\nMeeting',
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondary,
                    colorScheme.secondary.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: _showCreateSheet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentMeetings(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<StorageService>(
      builder: (context, storage, _) {
        final meetings = storage.meetingHistory;
        final recentMeetings = meetings.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Meetings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (meetings.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.history),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentMeetings.isEmpty)
              _buildEmptyState(theme, colorScheme)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentMeetings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return MeetingHistoryCard(
                    meeting: recentMeetings[index],
                    onTap: () => _rejoinMeeting(recentMeetings[index]),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withAlpha(20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 48,
            color: colorScheme.onSurface.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            'No meetings yet',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(160),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join or create a meeting to get started',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
