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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              // CircleAvatar(
              //   radius: 22,
              //   backgroundColor: theme.colorScheme.primaryContainer,
              //   child: Text(
              //     _initials,
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 14,
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      patient.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
              if (patient.gender != null) _GenderChip(gender: patient.gender!),
              const SizedBox(height: 8),
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
        color: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isMale ? 'ذكر' : 'أنثى',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isMale ? Colors.blue.shade700 : Colors.pink.shade700,
        ),
      ),
    );
  }
}
