import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/database/app_database.dart';
import 'package:template/core/teeth_selector/teeth_selector.dart';
import 'package:template/core/utils/date_helper.dart';
import 'package:template/core/utils/snackbars.dart';
import 'package:template/features/patients/models/patient_model.dart';
import 'package:template/features/patients/widgets/patient_selector_field.dart';

import '../providers/appointments_providers.dart';

class PendingTreatment {
  PendingTreatment({
    required this.treatmentType,
    this.toothNumber,
    required this.price,
    this.notes,
  });
  final String treatmentType;
  final int? toothNumber;
  final double price;
  final String? notes;

  TreatmentsTableCompanion toCompanion(int patientId) {
    return TreatmentsTableCompanion.insert(
      patientId: patientId,
      treatmentType: treatmentType,
      toothNumber: drift.Value(toothNumber),
      price: drift.Value(price),
      notes: drift.Value(notes),
      status: const drift.Value('planned'),
    );
  }
}

class AddAppointmentPage extends ConsumerStatefulWidget {
  const AddAppointmentPage({
    super.key,
    required this.initialDate,
    this.preselectedPatientId,
  });
  final DateTime initialDate;

  /// When non-null the patient field is pre-filled and locked.
  final int? preselectedPatientId;

  @override
  ConsumerState<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends ConsumerState<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  PatientModel? _selectedPatient;

  final List<PendingTreatment> _pendingTreatments = [];
  bool _showTreatmentForm = false;
  int? _filterToothNumber;

  // Treatment Form State
  final _treatmentTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _treatmentNotesController = TextEditingController();
  int? _selectedToothNumber;

  final List<String> _commonTreatments = [
    'فحص',
    'تنظيف وتلميع',
    'حشوة ضوئية',
    'سحب عصب',
    'قلع',
    'تلبيسة',
    'جسر',
    'طقم أسنان',
    'تقويم أسنان',
    'زراعة أسنان',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _treatmentTypeController.dispose();
    _priceController.dispose();
    _treatmentNotesController.dispose();
    super.dispose();
  }

  void _addTreatment() {
    if (_treatmentTypeController.text.isEmpty) {
      AppSnackBar.error('يرجى اختيار نوع العلاج');
      return;
    }
    final price = double.tryParse(_priceController.text) ?? 0.0;

    setState(() {
      _pendingTreatments.add(
        PendingTreatment(
          treatmentType: _treatmentTypeController.text.trim(),
          toothNumber: _selectedToothNumber,
          price: price,
          notes: _treatmentNotesController.text.trim().isEmpty
              ? null
              : _treatmentNotesController.text.trim(),
        ),
      );
      _resetTreatmentForm();
    });
  }

  void _resetTreatmentForm() {
    _treatmentTypeController.clear();
    _priceController.clear();
    _treatmentNotesController.clear();
    _selectedToothNumber = null;
    _showTreatmentForm = false;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(appointmentFormProvider);
    final isLoading = formState.isLoading;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موعد جديد'),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check,

                        color: Colors.white,
                      ),
                label: const Text(
                  'حفظ الموعد',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Section (Form) ──────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('المريض *'),
                    const SizedBox(height: 8),
                    PatientSelectorField(
                      initialPatientId: widget.preselectedPatientId,
                      onChanged: (p) => setState(() => _selectedPatient = p),
                      validator: (p) => p == null ? 'يرجى اختيار المريض' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    pattern: 'EEEE، dd MMMM yyyy',
                                  ),
                                ),
                                onPressed: _pickDate,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('الوقت *'),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                style: _pickerStyle(theme),
                                icon: const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  DateHelper.time(
                                    DateTime(
                                      0,
                                      0,
                                      0,
                                      _selectedTime.hour,
                                      _selectedTime.minute,
                                    ),
                                  ),
                                ),
                                onPressed: _pickTime,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('ملاحظات الموعد'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      textDirection: TextDirection.rtl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'أضف أي ملاحظات إضافية هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                      ),
                    ),
                    if (!isDesktop) ...[
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildTreatmentSection(theme),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Right Section (Treatments) ─────────────────────
          if (isDesktop)
            Container(
              width: 450,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                color: theme.colorScheme.surfaceContainerLow,
              ),
              child: _buildTreatmentSection(theme),
            ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'حفظ الموعد',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildTreatmentSection(ThemeData theme) {
    final filteredTreatments = _filterToothNumber == null
        ? _pendingTreatments
        : _pendingTreatments
              .where((t) => t.toothNumber == _filterToothNumber)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الإجراءات والعلاجات',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (!_showTreatmentForm)
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showTreatmentForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة إجراء'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('تصفية حسب السن:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                height: 333,
                child: TeethSelector(
                  multiSelect: false,
                  selectedColor: theme.colorScheme.secondary,
                  // unselectedColor: theme.colorScheme.surfaceContainerHighest,
                  onChange: (selected) {
                    setState(() {
                      _filterToothNumber = selected.isEmpty
                          ? null
                          : int.tryParse(selected.last);
                    });
                  },
                ),
              ),
              if (_filterToothNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        'عرض علاجات السن: $_filterToothNumber',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            setState(() => _filterToothNumber = null),
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_showTreatmentForm) _buildTreatmentForm(theme),
        Expanded(
          child: filteredTreatments.isEmpty
              ? _buildEmptyTreatments(theme)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredTreatments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final t = filteredTreatments[index];
                    return _TreatmentCard(
                      treatment: t,
                      onDelete: () =>
                          setState(() => _pendingTreatments.remove(t)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTreatmentForm(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إضافة إجراء جديد',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return _commonTreatments;
              }
              return _commonTreatments.where((String option) {
                return option.contains(textEditingValue.text);
              });
            },
            onSelected: (String selection) {
              _treatmentTypeController.text = selection;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'نوع الإجراء *',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'السعر',
                    prefixIcon: const Icon(Icons.attach_money, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
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
                        _selectedToothNumber == null
                            ? 'السن: كلي'
                            : 'السن: $_selectedToothNumber',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('اختر السن (اختياري):'),
          const SizedBox(height: 8),
          SizedBox(
            height: 333,
            child: TeethSelector(
              multiSelect: false,
              selectedColor: theme.colorScheme.primary,
              // unselectedColor: theme.colorScheme.surfaceContainerHighest,
              onChange: (selected) {
                setState(() {
                  _selectedToothNumber = selected.isEmpty
                      ? null
                      : int.tryParse(selected.last);
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetTreatmentForm,
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _addTreatment,
                  child: const Text(
                    'إضافة',

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTreatments(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 48,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إجراءات مضافة لهذا الموعد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
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
    if (_selectedPatient == null) {
      AppSnackBar.error('يرجى اختيار المريض');
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final treatments = _pendingTreatments
        .map((t) => t.toCompanion(_selectedPatient!.id))
        .toList();

    final success = await ref
        .read(appointmentFormProvider.notifier)
        .createAppointmentWithTreatments(
          patientId: _selectedPatient!.id,
          date: dateTime,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          treatments: treatments,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      AppSnackBar.success('تمت إضافة الموعد بنجاح');
    }
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.treatment, required this.onDelete});
  final PendingTreatment treatment;
  final VoidCallback onDelete;

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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.healing_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.treatmentType,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (treatment.toothNumber != null) ...[
                        Text(
                          'السن: ${treatment.toothNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '${treatment.price} ₺',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: theme.colorScheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
