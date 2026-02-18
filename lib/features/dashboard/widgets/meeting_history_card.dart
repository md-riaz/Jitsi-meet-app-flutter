import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:alora_meet/core/models/meeting.dart';

class MeetingHistoryCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;

  const MeetingHistoryCard({
    super.key,
    required this.meeting,
    required this.onTap,
  });

  String get _title =>
      (meeting.subject != null && meeting.subject!.isNotEmpty)
          ? meeting.subject!
          : meeting.roomName;

  String get _formattedDate {
    final now = DateTime.now();
    final date = meeting.createdAt;
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays == 0) return 'Today, ${DateFormat.jm().format(date)}';
    if (diff.inDays == 1) return 'Yesterday, ${DateFormat.jm().format(date)}';
    if (diff.inDays < 7) return DateFormat('EEEE, h:mm a').format(date);
    return DateFormat('MMM d, y · h:mm a').format(date);
  }

  String? get _duration {
    if (meeting.durationMinutes == null || meeting.durationMinutes == 0) {
      return null;
    }
    final mins = meeting.durationMinutes!;
    if (mins < 60) return '${mins}min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String get _serverLabel {
    final uri = Uri.tryParse(meeting.serverURL);
    return uri?.host ?? meeting.serverURL;
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.videocam_rounded,
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
                    Text(
                      _title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (meeting.creatorName != null &&
                            meeting.creatorName!.isNotEmpty) ...[
                          Icon(Icons.person_outline,
                              size: 13,
                              color: colorScheme.onSurface.withAlpha(120)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              meeting.creatorName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withAlpha(140),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _dot(colorScheme),
                        ],
                        Text(
                          _formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(120),
                            fontSize: 12,
                          ),
                        ),
                        if (_duration != null) ...[
                          _dot(colorScheme),
                          Text(
                            _duration!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(120),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _serverLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withAlpha(160),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing rejoin icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
        ),
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
