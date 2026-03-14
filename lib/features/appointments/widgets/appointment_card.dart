import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onStatusChange,
    required this.onDelete,
  });
  final AppointmentModel appointment;
  final ValueChanged<AppointmentStatus> onStatusChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(appointment.status, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Time column
            Column(
              children: [
                Text(
                  appointment.timeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 2,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        appointment.patient?.fullName ??
                            'مريض #${appointment.patientId}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(status: appointment.status),
                    ],
                  ),
                  if (appointment.notes != null &&
                      appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      appointment.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (_) => [
                ..._statusActions(appointment.status),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                } else {
                  onStatusChange(AppointmentStatus.fromDb(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuItem<String>> _statusActions(AppointmentStatus current) {
    const all = AppointmentStatus.values;
    return all
        .where((s) => s != current)
        .map(
          (s) => PopupMenuItem(
            value: s.dbValue,
            child: Row(
              children: [
                Icon(_statusIcon(s), size: 18, color: _rawStatusColor(s)),
                const SizedBox(width: 8),
                Text(s.arabicLabel),
              ],
            ),
          ),
        )
        .toList();
  }

  Color _statusColor(AppointmentStatus status, ThemeData theme) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return theme.colorScheme.primary;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }

  Color _rawStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }

  IconData _statusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.noShow:
        return Icons.person_off_outlined;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case AppointmentStatus.scheduled:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case AppointmentStatus.completed:
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case AppointmentStatus.cancelled:
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      case AppointmentStatus.noShow:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.arabicLabel,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
