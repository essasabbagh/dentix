import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dentix/core/teeth_selector/teeth_selector.dart';
import 'package:dentix/core/utils/date_helper.dart';
import 'package:dentix/features/appointments/models/appointment_model.dart';
import 'package:dentix/features/appointments/providers/appointments_providers.dart';

class AppointmentDetailsPage extends ConsumerStatefulWidget {
  const AppointmentDetailsPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<AppointmentDetailsPage> createState() =>
      _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState
    extends ConsumerState<AppointmentDetailsPage> {
  int? _hoveredToothNumber;

  @override
  Widget build(BuildContext context) {
    final appointmentAsync = ref.watch(
      appointmentWithTreatmentsProvider(widget.id),
    );
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الموعد',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: appointmentAsync.when(
        data: (appointment) {
          if (appointment == null) {
            return const Center(child: Text('الموعد غير موجود'));
          }
          final totalPrice = appointment.treatments.fold<double>(
            0,
            (sum, t) => sum + t.price,
          );

          // Highlight teeth that have treatments in this appointment
          final teethWithTreatments = {
            for (final t in appointment.treatments)
              if (t.toothNumber != null)
                t.toothNumber.toString(): theme.colorScheme.primaryContainer,
          };

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Patient Info ──────────────────────────
              _buildSectionTitle(theme, 'معلومات المريض'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    appointment.patient?.fullName ?? 'مريض غير معروف',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patient?.phone ?? '',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Appointment Info ──────────────────────
              _buildSectionTitle(theme, 'معلومات الموعد'),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        theme,
                        Icons.calendar_today,
                        'التاريخ',
                        DateHelper.format(
                          appointment.appointmentDate,
                          pattern: 'EEEE، dd MMMM yyyy',
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        theme,
                        Icons.access_time,
                        'الوقت',
                        DateHelper.time(
                          appointment.appointmentDate,
                          locale: 'en',
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        theme,
                        Icons.info_outline,
                        'الحالة',
                        appointment.status.arabicLabel,
                        valueColor: _getStatusColor(appointment.status),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Notes ─────────────────────────────────
              if (appointment.notes != null) ...[
                _buildSectionTitle(theme, 'ملاحظات'),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      appointment.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Treatments Section ────────────────────
              _buildSectionTitle(theme, 'الإجراءات والعلاجات'),
              const SizedBox(height: 8),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTreatmentsTable(
                        appointment,
                        totalPrice,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildOdontogramSide(
                        theme,
                        teethWithTreatments,
                        _hoveredToothNumber,
                      ),
                    ),
                  ],
                )
              else ...[
                _buildTreatmentsTable(appointment, totalPrice, theme),
                const SizedBox(height: 16),
                _buildOdontogramSide(
                  theme,
                  teethWithTreatments,
                  _hoveredToothNumber,
                ),
              ],
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: content,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Widget _buildTreatmentsTable(
    AppointmentModel appointment,
    double totalPrice,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          if (appointment.treatments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد علاجات مضافة لهذا الموعد'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointment.treatments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final t = appointment.treatments[index];
                return MouseRegion(
                  onEnter: (_) =>
                      setState(() => _hoveredToothNumber = t.toothNumber),
                  onExit: (_) => setState(() => _hoveredToothNumber = null),
                  child: ListTile(
                    title: Text(t.treatmentType),
                    subtitle: t.toothNumber != null
                        ? Text('السن: ${t.toothNumber}')
                        : null,
                    trailing: Text(
                      '${t.price} ₺',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalPrice ₺',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdontogramSide(
    ThemeData theme,
    Map<String, Color> colorized,
    int? highlightedTooth,
  ) {
    final effectiveColorized = Map<String, Color>.from(colorized);
    if (highlightedTooth != null) {
      effectiveColorized[highlightedTooth.toString()] =
          theme.colorScheme.secondary;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'مخطط الأسنان',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TeethSelector(
                multiSelect: false,
                selectedColor: theme.colorScheme.secondary,
                colorized: effectiveColorized,
                onChange: (_) {},
              ),
            ),
            if (highlightedTooth != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'السن المحدد: $highlightedTooth',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.scheduled => Colors.blue,
      AppointmentStatus.completed => Colors.green,
      AppointmentStatus.cancelled => Colors.red,
      AppointmentStatus.noShow => Colors.orange,
    };
  }
}
