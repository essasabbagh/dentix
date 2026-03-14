import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/utils/date_helper.dart';
import 'package:template/core/utils/snackbars.dart';

import '../models/patient_model.dart';
import '../providers/patients_providers.dart';

class AddEditPatientPage extends ConsumerStatefulWidget {
  // null = add mode

  const AddEditPatientPage({super.key, this.patient});
  final PatientModel? patient;

  @override
  ConsumerState<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends ConsumerState<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  String? _gender;
  DateTime? _birthDate;

  bool get _isEditMode => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _firstName = TextEditingController(text: p?.firstName ?? '');
    _lastName = TextEditingController(text: p?.lastName ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _notes = TextEditingController(text: p?.notes ?? '');
    _gender = p?.gender;
    _birthDate = p?.birthDate;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(patientFormProvider);
    final isLoading = formState.isLoading;
    final theme = Theme.of(context);

    ref.listen(patientFormProvider, (_, next) {
      if (next.hasError) {
        AppSnackBar.error(next.error.toString());
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // ── Dialog header ────────────────────────────────
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
                    Icon(
                      _isEditMode
                          ? Icons.edit_outlined
                          : Icons.person_add_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isEditMode ? 'تعديل بيانات المريض' : 'إضافة مريض جديد',
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
              // ── Form body ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name row
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: _firstName,
                                label: 'الاسم الأول *',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: _lastName,
                                label: 'اسم العائلة *',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Phone
                        _buildField(
                          controller: _phone,
                          label: 'رقم الهاتف *',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (v.length < 9) return 'رقم غير صحيح';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _buildField(
                          controller: _email,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        // Gender
                        _buildLabel('الجنس'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _GenderButton(
                              label: 'ذكر',
                              value: 'male',
                              selected: _gender == 'male',
                              icon: Icons.male,
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                            const SizedBox(width: 10),
                            _GenderButton(
                              label: 'أنثى',
                              value: 'female',
                              selected: _gender == 'female',
                              icon: Icons.female,
                              color: Colors.pink,
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Birth date
                        _buildLabel('تاريخ الميلاد'),
                        const SizedBox(height: 8),
                        _BirthDatePicker(
                          value: _birthDate,
                          onChanged: (d) => setState(() => _birthDate = d),
                        ),
                        const SizedBox(height: 16),
                        // Address
                        _buildField(
                          controller: _address,
                          label: 'العنوان',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        // Notes
                        _buildField(
                          controller: _notes,
                          label: 'ملاحظات',
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Footer buttons ───────────────────────────────
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
                          : Icon(
                              _isEditMode ? Icons.save_outlined : Icons.add,

                              color: Colors.white,
                            ),
                      label: Text(
                        _isEditMode ? 'حفظ التعديلات' : 'إضافة',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(patientFormProvider.notifier);
    bool success;

    if (_isEditMode) {
      final updated = widget.patient!.copyWith(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        gender: _gender,
        birthDate: _birthDate,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        updatedAt: DateTime.now(),
      );
      success = await notifier.updatePatient(updated);
    } else {
      success = await notifier.createPatient(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        gender: _gender,
        birthDate: _birthDate,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      AppSnackBar.success(
        _isEditMode ? 'تم تحديث بيانات المريض' : 'تمت إضافة المريض',
      );
    }
  }
}

// ── Gender selector button ────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.icon,
    required this.onTap,
    this.color = Colors.blue,
  });
  final String label;
  final String value;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? color : theme.colorScheme.outline,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? color : theme.colorScheme.outline,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Birth date picker ─────────────────────────────────────────────────────

class _BirthDatePicker extends StatelessWidget {
  const _BirthDatePicker({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = value != null
        ? DateHelper.format(value!, pattern: 'yyyy/MM/dd')
        : 'اختر تاريخ الميلاد';

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.centerRight,
      ),
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(label),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1990),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          locale: const Locale('ar'),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
