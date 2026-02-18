import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:alora_meet/core/models/meeting.dart';

class HistoryMeetingTile extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryMeetingTile({
    super.key,
    required this.meeting,
    required this.onTap,
    required this.onDelete,
  });

  String get _title =>
      (meeting.subject != null && meeting.subject!.isNotEmpty)
          ? meeting.subject!
          : meeting.roomName;

  String get _formattedDate {
    return DateFormat("MMM d, y 'at' h:mm a").format(meeting.createdAt);
  }

  String get _duration {
    if (meeting.durationMinutes == null) return 'N/A';
    final mins = meeting.durationMinutes!;
    if (mins == 0) return 'N/A';
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '$h hr $m min' : '$h hr';
  }

  String get _serverLabel {
    final uri = Uri.tryParse(meeting.serverURL);
    return uri?.host ?? meeting.serverURL;
  }

  IconData get _meetingIcon {
    if (meeting.scheduledFor != null) return Icons.event_rounded;
    if (meeting.password != null && meeting.password!.isNotEmpty) {
      return Icons.lock_rounded;
    }
    return Icons.videocam_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Leading icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _meetingIcon,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Duration badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _duration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (meeting.subject != null &&
                        meeting.subject!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meeting.roomName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withAlpha(130),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    // Date and creator row
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12,
                            color: colorScheme.onSurface.withAlpha(110)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(130),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (meeting.creatorName != null &&
                            meeting.creatorName!.isNotEmpty) ...[
                          _dot(colorScheme),
                          Icon(Icons.person_outline,
                              size: 12,
                              color: colorScheme.onSurface.withAlpha(110)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              meeting.creatorName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withAlpha(130),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Server row
                    Row(
                      children: [
                        Icon(Icons.dns_outlined,
                            size: 11,
                            color: colorScheme.primary.withAlpha(140)),
                        const SizedBox(width: 4),
                        Text(
                          _serverLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary.withAlpha(160),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Trailing delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: colorScheme.onSurface.withAlpha(80),
                ),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Remove "$_title" from your history?'),
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
              onDelete();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.circle,
        size: 3,
        color: colorScheme.onSurface.withAlpha(80),
      ),
    );
  }
}
