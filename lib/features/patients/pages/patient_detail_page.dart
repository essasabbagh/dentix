import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../models/patient_model.dart';
import '../providers/patients_providers.dart';

import 'add_edit_patient_page.dart';

class PatientDetailPage extends ConsumerWidget {
  const PatientDetailPage({super.key, required this.patientId});
  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: patientAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (patient) {
            if (patient == null) {
              return const Center(child: Text('المريض غير موجود'));
            }
            return CustomScrollView(
              slivers: [
                _PatientSliverAppBar(patient: patient),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _InfoSection(patient: patient),
                      const SizedBox(height: 20),
                      // Future: appointments, treatments, payments tabs here
                      const _PlaceholderSection(
                        title: 'المواعيد',
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 12),
                      const _PlaceholderSection(
                        title: 'العلاجات',
                        icon: Icons.healing_outlined,
                      ),
                      const SizedBox(height: 12),
                      const _PlaceholderSection(
                        title: 'المدفوعات',
                        icon: Icons.payments_outlined,
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Sliver app bar ────────────────────────────────────────────────────────

class _PatientSliverAppBar extends ConsumerWidget {
  const _PatientSliverAppBar({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'تعديل',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AddEditPatientPage(patient: patient),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          tooltip: 'حذف',
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: theme.colorScheme.primaryContainer,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _initials,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        patient.phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _initials {
    final f = patient.firstName.isNotEmpty ? patient.firstName[0] : '';
    final l = patient.lastName.isNotEmpty ? patient.lastName[0] : '';
    return '$f$l';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المريض'),
        content: Text('هل تريد حذف المريض "${patient.fullName}" نهائياً؟'),
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
      await ref.read(patientFormProvider.notifier).deletePatient(patient.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

// ── Info section ──────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الشخصية',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'الجنس',
              value: patient.genderLabel,
            ),
            if (patient.birthDate != null)
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'تاريخ الميلاد',
                value:
                    '${DateFormat('yyyy/MM/dd').format(patient.birthDate!)} (${patient.age} سنة)',
              ),
            if (patient.email != null && patient.email!.isNotEmpty)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'البريد',
                value: patient.email!,
              ),
            if (patient.address != null && patient.address!.isNotEmpty)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'العنوان',
                value: patient.address!,
              ),
            if (patient.notes != null && patient.notes!.isNotEmpty)
              _InfoRow(
                icon: Icons.notes_outlined,
                label: 'ملاحظات',
                value: patient.notes!,
              ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ التسجيل',
              value: DateFormat('yyyy/MM/dd').format(patient.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left),
        subtitle: Text(
          'سيتم الإضافة قريباً',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
