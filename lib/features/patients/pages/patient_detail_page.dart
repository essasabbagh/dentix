import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/components/loading/loading_widget.dart';
import 'package:dentix/components/ui/whatsapp_button.dart';
import 'package:dentix/core/database/app_database.dart';
import 'package:dentix/core/extensions/context_ext.dart';
import 'package:dentix/core/teeth_selector/teeth_selector.dart';
import 'package:dentix/core/themes/app_colors.dart';
import 'package:dentix/core/utils/date_helper.dart';
import 'package:dentix/core/utils/snackbars.dart';
import 'package:dentix/features/appointments/models/appointment_model.dart';
import 'package:dentix/features/appointments/pages/add_appointment_page.dart';
import 'package:dentix/features/appointments/providers/appointments_providers.dart';
import 'package:dentix/features/assets/widgets/assets_section.dart';
import 'package:dentix/features/payments/models/payment_model.dart';
import 'package:dentix/features/payments/providers/payments_providers.dart';
import 'package:dentix/features/treatments/models/treatment_model.dart';
import 'package:dentix/features/treatments/providers/treatment_templates_providers.dart';
import 'package:dentix/features/treatments/providers/treatments_providers.dart';

import '../models/patient_model.dart';
import '../providers/patients_providers.dart';

import 'add_edit_patient_page.dart';

class PatientDetailPage extends ConsumerWidget {
  const PatientDetailPage({
    super.key,
    required this.patientId,
  });

  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientByIdProvider(patientId));

    return patientAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (patient) {
        if (patient == null) {
          return const Scaffold(
            body: Center(child: Text('المريض غير موجود')),
          );
        }
        return _PatientDetailScaffold(patient: patient);
      },
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
              backgroundColor: AppColors.primaryColor,
              title: Text(
                patient.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
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
              bottom: TabBar(
                labelColor: theme.colorScheme.secondary,
                unselectedLabelColor: Colors.white,
                indicatorColor: theme.colorScheme.secondary,
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
      builder: (context) => AlertDialog(
        title: const Text('حذف المريض'),
        content: Text(
          'هل تريد حذف المريض "${patient.fullName}" نهائياً؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.white),
            ),
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
                    '${DateHelper.format(patient.birthDate!)} — '
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
              value:
                  '${DateHelper.format(
                    patient.createdAt,
                  )} ${DateHelper.format(
                    patient.createdAt,
                    pattern: 'EEEE, MMMM',
                    locale: 'tr',
                  )}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        AssetsSection(
          assetContext: AssetContext.patient,
          ownerId: patient.id,
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
      loading: LoadingWidget.new,
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
                    itemBuilder: (_, i) => _AppointmentTile(
                      appointment: appointments[i],
                      patient: patient,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  const _AppointmentTile({required this.appointment, required this.patient});

  final AppointmentModel appointment;
  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = appointment.status.statusColor;

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
                    DateHelper.format(
                      appointment.appointmentDate,
                      pattern: 'd/M',
                    ),
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
                  if (appointment.notes?.isNotEmpty == true)
                    Text(
                      appointment.notes ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            WhatsAppButton(
              phone: patient.phone,
              message: appointment
                  .copyWith(patient: patient)
                  .generateWhatsAppMessage(),
            ),
            PopupMenuButton<String>(
              child: _StatusBadge(
                label: appointment.status.arabicLabel,
                color: statusColor,
              ),
              itemBuilder: (_) => [
                ..._statusActions(appointment.status),
              ],
              onSelected: (value) {
                ref
                    .read(appointmentFormProvider.notifier)
                    .updateStatus(
                      appointment.id,
                      AppointmentStatus.fromDb(value),
                    );
              },
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

  Color _rawStatusColor(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.noShow => Colors.orange,
    };
  }

  IconData _statusIcon(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.scheduled => Icons.schedule,
      AppointmentStatus.completed => Icons.check_circle_outline,
      AppointmentStatus.cancelled => Icons.cancel_outlined,
      AppointmentStatus.noShow => Icons.person_off_outlined,
    };
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
      loading: LoadingWidget.new,
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
    final statusColor = treatment.status.statusColor;

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
                        DateHelper.format(
                          treatment.createdAt,
                          pattern: 'yyyy/MM/dd',
                        ),
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
                  '${treatment.price.toStringAsFixed(0)} ₺',
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
      loading: LoadingWidget.new,
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
              data: (total) => _PaymentsTotalBar(
                payments: payments,
                totalPaid: total,
              ),
              orElse: () => const SizedBox.shrink(),
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
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.payments_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelper.format(
                      payment.paymentDate,
                      pattern: 'yyyy/MM/dd',
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
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
                  '${payment.amount.toStringAsFixed(0)} ₺',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
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
    final templatesAsync = ref.watch(treatmentTemplatesProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : 460,
          maxHeight: isDesktop ? 600 : 700,
        ),
        child: Column(
          children: [
            const _DialogHeader(
              title: 'إضافة علاج جديد',
              icon: Icons.healing_outlined,
            ),
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: _buildForm(templatesAsync, theme),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildOdontogramSection(theme),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildForm(templatesAsync, theme),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildOdontogramSection(theme),
                        ],
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
    );
  }

  Widget _buildForm(
    AsyncValue<List<TreatmentTemplatesTableData>> templatesAsync,
    ThemeData theme,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل العلاج',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          templatesAsync.when(
            data: (templates) => Autocomplete<TreatmentTemplatesTableData>(
              displayStringForOption: (option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return templates;
                return templates.where(
                  (option) => option.name.contains(textEditingValue.text),
                );
              },
              onSelected: (selection) {
                _typeController.text = selection.name;
                _priceController.text = selection.defaultPrice.toString();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    controller.addListener(() {
                      _typeController.text = controller.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textDirection: TextDirection.rtl,
                      decoration: _dec(
                        'نوع العلاج *',
                        Icons.medical_services_outlined,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    );
                  },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          _field(
            controller: _priceController,
            label: 'السعر (₺) *',
            icon: Icons.attach_money,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'مطلوب';
              if (double.tryParse(v) == null) return 'أدخل رقماً صحيحاً';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _toothNumber == null ? 'السن: كلي' : 'السن: $_toothNumber',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field(
            controller: _notesController,
            label: 'ملاحظات',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOdontogramSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر السن',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: TeethSelector(
              multiSelect: false,
              selectedColor: theme.colorScheme.secondary,
              onChange: (selected) {
                setState(() {
                  _toothNumber = selected.isEmpty
                      ? null
                      : int.tryParse(selected.last);
                });
              },
            ),
          ),
        ),
        if (_toothNumber != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Text(
                  'السن المحدد: $_toothNumber',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _toothNumber = null),
                  child: const Text(
                    'إلغاء التحديد',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    inputFormatters: inputFormatters,
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
      AppSnackBar.success('تمت إضافة العلاج');
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

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(paymentFormProvider).isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 320),
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
                            labelText: 'المبلغ (₺) *',
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
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
    if (ok && mounted) {
      Navigator.pop(context);
      AppSnackBar.success('تمت إضافة الدفعة');
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
          Icon(
            icon,
            size: 17,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
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
            icon: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
            ),
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
          '${value.toStringAsFixed(0)} ₺',
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
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
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
            child: Text(
              'إلغاء',
              style: context.theme.textTheme.bodyMedium,
            ),
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
                : const Icon(
                    Icons.save_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
            label: const Text(
              'حفظ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
