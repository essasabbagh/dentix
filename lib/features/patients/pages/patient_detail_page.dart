import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:template/features/appointments/models/appointment_model.dart';
import 'package:template/features/appointments/pages/add_appointment_page.dart';
import 'package:template/features/appointments/providers/appointments_providers.dart';
import 'package:template/features/patients/providers/patients_providers.dart';
import 'package:template/features/payments/models/payment_model.dart';
import 'package:template/features/payments/providers/payments_providers.dart';
import 'package:template/features/treatments/models/treatment_model.dart';
import 'package:template/features/treatments/providers/treatments_providers.dart';

import '../models/patient_model.dart';

import 'add_edit_patient_page.dart';

class PatientDetailPage extends ConsumerWidget {
  const PatientDetailPage({super.key, required this.patientId});
  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: patientAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
        data: (patient) {
          if (patient == null) {
            return const Scaffold(
              body: Center(child: Text('المريض غير موجود')),
            );
          }
          return _PatientDetailScaffold(patient: patient);
        },
      ),
    );
  }
}

// ── Main scaffold with tab controller ─────────────────────────────────────

class _PatientDetailScaffold extends ConsumerWidget {
  const _PatientDetailScaffold({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 170,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
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
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'حذف',
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _PatientHeader(patient: patient),
              ),
              bottom: TabBar(
                tabs: const [
                  Tab(
                    icon: Icon(Icons.info_outline, size: 18),
                    text: 'المعلومات',
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_month_outlined, size: 18),
                    text: 'المواعيد',
                  ),
                  Tab(
                    icon: Icon(Icons.healing_outlined, size: 18),
                    text: 'العلاجات',
                  ),
                  Tab(
                    icon: Icon(Icons.payments_outlined, size: 18),
                    text: 'المدفوعات',
                  ),
                ],
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _InfoTab(patient: patient),
              _AppointmentsTab(patient: patient),
              _TreatmentsTab(patient: patient),
              _PaymentsTab(patient: patient),
            ],
          ),
        ),
      ),
    );
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

// ── Patient header ─────────────────────────────────────────────────────────

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              _initials,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient.phone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    if (patient.age != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${patient.age} سنة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _initials {
    final f = patient.firstName.isNotEmpty ? patient.firstName[0] : '';
    final l = patient.lastName.isNotEmpty ? patient.lastName[0] : '';
    return '$f$l';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — Info
// ═════════════════════════════════════════════════════════════════════════════

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'المعلومات الشخصية',
          icon: Icons.badge_outlined,
          children: [
            _InfoRow(
              icon: Icons.wc_outlined,
              label: 'الجنس',
              value: patient.genderLabel,
            ),
            if (patient.birthDate != null)
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'تاريخ الميلاد',
                value:
                    '${DateFormat('yyyy/MM/dd').format(patient.birthDate!)} — '
                    '${patient.age} سنة',
              ),
            if (patient.email?.isNotEmpty == true)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'البريد',
                value: patient.email!,
              ),
            if (patient.address?.isNotEmpty == true)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'العنوان',
                value: patient.address!,
              ),
            if (patient.notes?.isNotEmpty == true)
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
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — Appointments
// ═════════════════════════════════════════════════════════════════════════════

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptAsync = ref.watch(patientAppointmentsProvider(patient.id));

    return apptAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (appointments) => Column(
        children: [
          _ActionBar(
            label: 'إضافة موعد',
            icon: Icons.add,
            onTap: () => showDialog(
              context: context,
              builder: (_) => AddAppointmentPage(
                initialDate: DateTime.now(),
                preselectedPatientId: patient.id,
              ),
            ),
          ),
          Expanded(
            child: appointments.isEmpty
                ? const _EmptySection(
                    message: 'لا توجد مواعيد مسجّلة لهذا المريض',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _AppointmentTile(appointment: appointments[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  const _AppointmentTile({required this.appointment});
  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(appointment.status, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Date block
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d/M').format(appointment.appointmentDate),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    appointment.timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctorName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (appointment.notes?.isNotEmpty == true)
                    Text(
                      appointment.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _StatusBadge(
              label: appointment.status.arabicLabel,
              color: statusColor,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: () => ref
                  .read(appointmentFormProvider.notifier)
                  .deleteAppointment(appointment.id),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AppointmentStatus s, ThemeData t) {
    switch (s) {
      case AppointmentStatus.scheduled:
        return t.colorScheme.primary;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — Treatments
// ═════════════════════════════════════════════════════════════════════════════

class _TreatmentsTab extends ConsumerWidget {
  const _TreatmentsTab({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentsAsync = ref.watch(patientTreatmentsProvider(patient.id));

    return treatmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (treatments) => Column(
        children: [
          _ActionBar(
            label: 'إضافة علاج',
            icon: Icons.add,
            onTap: () => showDialog(
              context: context,
              builder: (_) => _AddTreatmentDialog(patientId: patient.id),
            ),
          ),
          if (treatments.isNotEmpty)
            _TreatmentsTotalBar(treatments: treatments),
          Expanded(
            child: treatments.isEmpty
                ? const _EmptySection(
                    message: 'لا توجد علاجات مسجّلة لهذا المريض',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: treatments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _TreatmentTile(treatment: treatments[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentsTotalBar extends StatelessWidget {
  const _TreatmentsTotalBar({required this.treatments});
  final List<TreatmentModel> treatments;

  @override
  Widget build(BuildContext context) {
    final total = treatments.fold<double>(0, (s, t) => s + t.price);
    final completed = treatments
        .where((t) => t.status == TreatmentStatus.completed)
        .fold<double>(0, (s, t) => s + t.price);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          _MiniStat(
            label: 'إجمالي',
            value: total,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 24),
          _MiniStat(label: 'مكتمل', value: completed, color: Colors.green),
          const SizedBox(width: 24),
          _MiniStat(
            label: 'متبقي',
            value: total - completed,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _TreatmentTile extends ConsumerWidget {
  const _TreatmentTile({required this.treatment});
  final TreatmentModel treatment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(treatment.status, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.treatmentType,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (treatment.toothNumber != null) ...[
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'سن ${treatment.toothNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        DateFormat('yyyy/MM/dd').format(treatment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (treatment.notes?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        treatment.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${treatment.price.toStringAsFixed(0)} ر.س',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(
                  label: treatment.status.arabicLabel,
                  color: statusColor,
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (_) => [
                if (treatment.status != TreatmentStatus.completed)
                  const PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text('تحديد كمكتمل'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'complete') {
                  ref
                      .read(treatmentFormProvider.notifier)
                      .complete(treatment.id);
                } else if (v == 'delete') {
                  ref.read(treatmentFormProvider.notifier).delete(treatment.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TreatmentStatus s, ThemeData t) {
    switch (s) {
      case TreatmentStatus.planned:
        return t.colorScheme.primary;
      case TreatmentStatus.inProgress:
        return Colors.orange;
      case TreatmentStatus.completed:
        return Colors.green;
      case TreatmentStatus.cancelled:
        return Colors.red;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 4 — Payments
// ═════════════════════════════════════════════════════════════════════════════

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(patientPaymentsProvider(patient.id));
    final totalPaid = ref.watch(patientTotalPaidProvider(patient.id));

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (payments) => Column(
        children: [
          _ActionBar(
            label: 'إضافة دفعة',
            icon: Icons.add,
            onTap: () => showDialog(
              context: context,
              builder: (_) => _AddPaymentDialog(patientId: patient.id),
            ),
          ),
          if (payments.isNotEmpty)
            totalPaid.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (total) => _PaymentsTotalBar(
                payments: payments,
                totalPaid: total,
              ),
            ),
          Expanded(
            child: payments.isEmpty
                ? const _EmptySection(
                    message: 'لا توجد مدفوعات مسجّلة لهذا المريض',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: payments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _PaymentTile(payment: payments[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsTotalBar extends StatelessWidget {
  const _PaymentsTotalBar({required this.payments, required this.totalPaid});
  final List<PaymentModel> payments;
  final double totalPaid;

  @override
  Widget build(BuildContext context) {
    final pending = payments
        .where((p) => p.paymentStatus == PaymentStatus.pending)
        .fold<double>(0, (s, p) => s + p.amount);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          _MiniStat(
            label: 'إجمالي المدفوع',
            value: totalPaid,
            color: Colors.green,
          ),
          const SizedBox(width: 24),
          _MiniStat(label: 'معلق', value: pending, color: Colors.orange),
        ],
      ),
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});
  final PaymentModel payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(payment.paymentStatus, theme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                _methodIcon(payment.paymentMethod),
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentMethod.arabicLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(payment.paymentDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (payment.notes?.isNotEmpty == true)
                    Text(
                      payment.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${payment.amount.toStringAsFixed(0)} ر.س',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                _StatusBadge(
                  label: payment.paymentStatus.arabicLabel,
                  color: statusColor,
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: () =>
                  ref.read(paymentFormProvider.notifier).delete(payment.id),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(PaymentStatus s, ThemeData t) {
    switch (s) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.partial:
        return t.colorScheme.primary;
    }
  }

  IconData _methodIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Icons.money_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.transfer:
        return Icons.account_balance_outlined;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Add Treatment Dialog
// ═════════════════════════════════════════════════════════════════════════════

class _AddTreatmentDialog extends ConsumerStatefulWidget {
  const _AddTreatmentDialog({required this.patientId});
  final int patientId;

  @override
  ConsumerState<_AddTreatmentDialog> createState() =>
      _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends ConsumerState<_AddTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  int? _toothNumber;

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(treatmentFormProvider).isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 520),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const _DialogHeader(
                title: 'إضافة علاج',
                icon: Icons.healing_outlined,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field(
                          controller: _typeController,
                          label: 'نوع العلاج *',
                          icon: Icons.medical_services_outlined,
                          validator: (v) => v?.isEmpty == true ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _priceController,
                          label: 'السعر (ر.س) *',
                          icon: Icons.attach_money,
                          keyboard: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'مطلوب';
                            if (double.tryParse(v!) == null) {
                              return 'أدخل رقماً';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.rtl,
                          decoration: _dec(
                            'رقم السن (اختياري)',
                            Icons.circle_outlined,
                          ),
                          onChanged: (v) => _toothNumber = int.tryParse(v),
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _notesController,
                          label: 'ملاحظات',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _DialogFooter(
                isLoading: isLoading,
                onCancel: () => Navigator.pop(context),
                onSave: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    maxLines: maxLines,
    textDirection: TextDirection.rtl,
    decoration: _dec(label, icon),
    validator: validator,
  );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(treatmentFormProvider.notifier)
        .create(
          patientId: widget.patientId,
          treatmentType: _typeController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          toothNumber: _toothNumber,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة العلاج'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Add Payment Dialog
// ═════════════════════════════════════════════════════════════════════════════

class _AddPaymentDialog extends ConsumerStatefulWidget {
  const _AddPaymentDialog({required this.patientId});
  final int patientId;

  @override
  ConsumerState<_AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<_AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  PaymentStatus _status = PaymentStatus.paid;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(paymentFormProvider).isLoading;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 520),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const _DialogHeader(
                title: 'إضافة دفعة',
                icon: Icons.payments_outlined,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'المبلغ (ر.س) *',
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty == true) return 'مطلوب';
                            if (double.tryParse(v!) == null) {
                              return 'أدخل رقماً';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'طريقة الدفع',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: PaymentMethod.values
                              .map(
                                (m) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: _ChoiceChip(
                                      label: m.arabicLabel,
                                      selected: _method == m,
                                      onTap: () => setState(() => _method = m),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حالة الدفع',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: PaymentStatus.values
                              .map(
                                (s) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: _ChoiceChip(
                                      label: s.arabicLabel,
                                      selected: _status == s,
                                      onTap: () => setState(() => _status = s),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notesController,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات',
                            prefixIcon: const Icon(
                              Icons.notes_outlined,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _DialogFooter(
                isLoading: isLoading,
                onCancel: () => Navigator.pop(context),
                onSave: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(paymentFormProvider.notifier)
        .create(
          patientId: widget.patientId,
          amount: double.parse(_amountController.text.trim()),
          method: _method,
          status: _status,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الدفعة'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
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
          Icon(icon, size: 17, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 16),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 52,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} ر.س',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            color: theme.colorScheme.onPrimaryContainer,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
  });
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 16),
            label: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
