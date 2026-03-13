import 'package:flutter/material.dart';

import '../models/patient_model.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final PatientModel patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (patient.age != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.cake_outlined,
                            size: 13,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${patient.age} سنة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Gender chip
              if (patient.gender != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _GenderChip(gender: patient.gender!),
                ),
              const Icon(Icons.chevron_right, size: 20),
            ],
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
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.gender});
  final String gender;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMale = gender == 'male';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMale
            ? theme.colorScheme.primaryContainer
            : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isMale ? 'ذكر' : 'أنثى',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isMale
              ? theme.colorScheme.onPrimaryContainer
              : Colors.pink.shade700,
        ),
      ),
    );
  }
}
