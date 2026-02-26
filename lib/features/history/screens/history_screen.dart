import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/models/meeting.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/features/history/widgets/history_meeting_tile.dart';
import 'package:alora_meet/shared/widgets/main_bottom_nav.dart';

enum _SortOption { date, duration, name }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.date;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Meeting> _filterAndSort(List<Meeting> meetings) {
    var filtered = meetings;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = meetings.where((m) {
        return m.roomName.toLowerCase().contains(query) ||
            (m.subject?.toLowerCase().contains(query) ?? false) ||
            (m.creatorName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    switch (_sortOption) {
      case _SortOption.date:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOption.duration:
        filtered.sort((a, b) =>
            (b.durationMinutes ?? 0).compareTo(a.durationMinutes ?? 0));
        break;
      case _SortOption.name:
        filtered.sort((a, b) {
          final aName = a.subject ?? a.roomName;
          final bName = b.subject ?? b.roomName;
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
    }
    return filtered;
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

  void _confirmClearAll() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'This will permanently delete all meeting history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface.withAlpha(160)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<StorageService>(context, listen: false)
                  .clearHistory();
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting History'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<StorageService>(
            builder: (context, storage, _) {
              if (storage.meetingHistory.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear all history',
                onPressed: _confirmClearAll,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
      body: Consumer<StorageService>(
        builder: (context, storage, _) {
          final allMeetings = storage.meetingHistory;

          if (allMeetings.isEmpty) {
            return _buildEmptyState(theme, colorScheme);
          }

          final filtered = _filterAndSort(List.of(allMeetings));

          return Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search meetings...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurface.withAlpha(100),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: colorScheme.onSurface.withAlpha(100),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Sort bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} meeting${filtered.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(130),
                      ),
                    ),
                    const Spacer(),
                    _SortChip(
                      label: 'Date',
                      selected: _sortOption == _SortOption.date,
                      onTap: () =>
                          setState(() => _sortOption = _SortOption.date),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: 'Duration',
                      selected: _sortOption == _SortOption.duration,
                      onTap: () =>
                          setState(() => _sortOption = _SortOption.duration),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: 'Name',
                      selected: _sortOption == _SortOption.name,
                      onTap: () =>
                          setState(() => _sortOption = _SortOption.name),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Meeting list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: colorScheme.onSurface.withAlpha(60),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matches found',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface.withAlpha(120),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try a different search term',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withAlpha(80),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final meeting = filtered[index];
                          return Dismissible(
                            key: ValueKey(meeting.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withAlpha(30),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.delete_rounded,
                                color: colorScheme.error,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Meeting'),
                                      content: const Text(
                                        'Remove this meeting from history?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: colorScheme.onSurface
                                                  .withAlpha(160),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              Provider.of<StorageService>(context,
                                      listen: false)
                                  .deleteMeeting(meeting.id);
                            },
                            child: HistoryMeetingTile(
                              meeting: meeting,
                              onTap: () => _rejoinMeeting(meeting),
                              onDelete: () {
                                Provider.of<StorageService>(context,
                                        listen: false)
                                    .deleteMeeting(meeting.id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
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
                Icons.history_rounded,
                size: 40,
                color: colorScheme.primary.withAlpha(120),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No meeting history',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withAlpha(180),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your past meetings will appear here.\nJoin or create a meeting to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(100),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withAlpha(80)
                : colorScheme.onSurface.withAlpha(30),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withAlpha(130),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
