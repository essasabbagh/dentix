import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/utils/date_helper.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/patients/models/patient_model.dart';
import 'package:template/features/patients/providers/patients_providers.dart';

import '../providers/appointments_providers.dart';

class AddAppointmentPage extends ConsumerStatefulWidget {
  const AddAppointmentPage({
    super.key,
    required this.initialDate,
    this.preselectedPatientId,
  });
  final DateTime initialDate;
  final int? preselectedPatientId;

  @override
  ConsumerState<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends ConsumerState<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _doctorController = TextEditingController(text: 'الدكتور');

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  PatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsListProvider);
    final formState = ref.watch(appointmentFormProvider);
    final isLoading = formState.isLoading;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'إضافة موعد جديد',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient selector
                      _buildLabel('المريض *'),
                      const SizedBox(height: 8),
                      patientsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('خطأ: $e'),
                        data: (patients) =>
                            DropdownButtonFormField<PatientModel>(
                              initialValue: _selectedPatient,
                              hint: const Text('اختر المريض'),
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              items: patients
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        '${p.fullName} — ${p.phone}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (p) =>
                                  setState(() => _selectedPatient = p),
                              validator: (v) =>
                                  v == null ? 'يرجى اختيار المريض' : null,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Date picker
                      _buildLabel('التاريخ *'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: _pickerStyle(theme),
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        label: Text(
                          DateHelper.format(
                            _selectedDate,
                            pattern: 'yyyy/MM/dd',
                          ),
                        ),
                        onPressed: _pickDate,
                      ),
                      const SizedBox(height: 16),
                      // Time picker
                      _buildLabel('الوقت *'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: _pickerStyle(theme),
                        icon: const Icon(
                          Icons.access_time_outlined,
                          size: 18,
                        ),
                        label: Text(_selectedTime.format(context)),
                        onPressed: _pickTime,
                      ),
                      const SizedBox(height: 16),
                      // Doctor name
                      TextFormField(
                        controller: _doctorController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'اسم الطبيب',
                          prefixIcon: const Icon(
                            Icons.medical_services_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      TextFormField(
                        controller: _notesController,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'ملاحظات',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                    label: const Text(
                      'حفظ الموعد',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.outline,
    ),
  );

  ButtonStyle _pickerStyle(ThemeData theme) => OutlinedButton.styleFrom(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    side: BorderSide(color: theme.colorScheme.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 0),
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final success = await ref
        .read(appointmentFormProvider.notifier)
        .createAppointment(
          patientId: _selectedPatient!.id,
          date: dateTime,
          doctorName: _doctorController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      AppSnackBar.success('تمت إضافة الموعد بنجاح');
    }
  }
}
