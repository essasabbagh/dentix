import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/components/loading/loading_widget.dart';

import '../providers/patients_providers.dart';
import '../widgets/patient_card.dart';
import '../widgets/patient_search_bar.dart';

import 'add_edit_patient_page.dart';
import 'patient_detail_page.dart';

class PatientsPage extends ConsumerWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          _PatientsHeader(),
          // ── Search ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: PatientSearchBar(),
          ),
          // ── List ────────────────────────────────────────────
          Expanded(
            child: patientsAsync.when(
              loading: LoadingWidget.new,
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'حدث خطأ: $e',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              data: (patients) {
                if (patients.isEmpty) {
                  return _EmptyState(
                    onAdd: () => _openAddPatient(context, ref),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  itemCount: patients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return PatientCard(
                      patient: patient,
                      onTap: () => _openPatientDetail(context, patient.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPatient(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('مريض جديد'),
      ),
    );
  }

  void _openAddPatient(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const AddEditPatientPage(),
    );
  }

  void _openPatientDetail(BuildContext context, int patientId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailPage(patientId: patientId),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _PatientsHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(patientsCountProvider);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المرضى',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              countAsync.when(
                data: (count) => Text(
                  '$count مريض مسجّل',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 72,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد مرضى بعد',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة أول مريض في العيادة',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('إضافة مريض'),
          ),
        ],
      ),
    );
  }
}
