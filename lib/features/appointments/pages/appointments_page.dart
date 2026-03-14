import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/loading/loading_widget.dart';
import 'package:template/core/utils/date_helper.dart';

import '../models/appointment_model.dart';
import '../providers/appointments_providers.dart';
import '../widgets/appointment_card.dart';

import 'add_appointment_page.dart';

class AppointmentsPage extends ConsumerWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsForDateProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _DateNavigator(selectedDate: selectedDate),
          _WeekStrip(selectedDate: selectedDate),
          const Divider(height: 1),
          Expanded(
            child: appointmentsAsync.when(
              loading: LoadingWidget.new,
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (appointments) {
                if (appointments.isEmpty) {
                  return _EmptyDay(
                    date: selectedDate,
                    onAdd: () => _openAdd(context, ref),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return AppointmentCard(
                      appointment: appointments[index],
                      onStatusChange: (status) => ref
                          .read(appointmentFormProvider.notifier)
                          .updateStatus(appointments[index].id, status),
                      onDelete: () =>
                          _confirmDelete(context, ref, appointments[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'موعد جديد',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) {
    final date = ref.read(selectedDateProvider);
    showDialog(
      context: context,
      builder: (_) => AddAppointmentPage(initialDate: date),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppointmentModel appt,
  ) async {
    // Use DateHelper.time for the appointment time label in the dialog
    final timeLabel = DateHelper.time(appt.appointmentDate);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الموعد'),
        content: Text(
          'هل تريد حذف موعد ${appt.patient?.fullName ?? ''} في $timeLabel؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(appointmentFormProvider.notifier).deleteAppointment(appt.id);
    }
  }
}

// ── Date navigator ────────────────────────────────────────────────────────

class _DateNavigator extends ConsumerWidget {
  const _DateNavigator({required this.selectedDate});
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المواعيد',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // DateHelper.format with full weekday + Syrian month + day/month/year
              Text(
                DateHelper.format(
                  selectedDate,
                  pattern: 'EEEE، dd MMMM yyyy',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                DateHelper.format(
                  selectedDate,
                  pattern: 'EEEE, dd MMMM yyyy',
                  locale: 'tr',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!isToday)
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state = DateTime(
                  now.year,
                  now.month,
                  now.day,
                );
              },
              child: Text('اليوم', style: theme.textTheme.bodyMedium),
            ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = selectedDate
                  .subtract(const Duration(days: 1));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = selectedDate.add(
                const Duration(days: 1),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── 7-day week strip ──────────────────────────────────────────────────────

class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.selectedDate});
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    final days = List.generate(
      7,
      (i) => selectedDate.subtract(Duration(days: 3 - i)),
    );

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((day) {
          final isSelected =
              day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          final isToday =
              day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          // DateHelper.format with 'EEE' gives the short weekday in Arabic
          // useEnglishNumbers: true so the day number stays as "3" not "٣"
          final shortDay = DateHelper.format(
            day,
            pattern: 'EEE',
            useEnglishNumbers: true,
          );
          final dayNumber = DateHelper.format(
            day,
            pattern: 'd',
            useEnglishNumbers: true,
          );

          return GestureDetector(
            onTap: () => ref.read(selectedDateProvider.notifier).state = day,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shortDay,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.date, required this.onAdd});
  final DateTime date;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isToday =
        date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? 'لا توجد مواعيد اليوم' : 'لا توجد مواعيد في هذا اليوم',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: Text(
              'إضافة موعد',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
