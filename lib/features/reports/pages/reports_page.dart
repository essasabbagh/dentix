import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:template/core/utils/date_helper.dart';

import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _ReportsAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _DateRangePicker(),
                const SizedBox(height: 20),
                _KpiRow(),
                const SizedBox(height: 20),
                _IncomeBarChart(),
                const SizedBox(height: 20),
                _AppointmentsBreakdown(),
                const SizedBox(height: 20),
                _TopTreatmentsCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────

class _ReportsAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      title: Row(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            color: theme.colorScheme.primary,
            size: 26,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التقارير',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                period.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Date Range Picker ─────────────────────────────────────────────────────

class _DateRangePicker extends ConsumerWidget {
  const _DateRangePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'تحديد الفترة الزمنيّة',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'من تاريخ',
                    date: period.start,
                    onTap: () => _pickDate(context, ref, true, period.start),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: 'إلى تاريخ',
                    date: period.end,
                    onTap: () => _pickDate(context, ref, false, period.end),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Common presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'هذا الشهر',
                    onTap: () => _setThisMonth(ref),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'الشهر الماضي',
                    onTap: () => _setLastMonth(ref),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'هذه السنة',
                    onTap: () => _setThisYear(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    bool isStart,
    DateTime initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.day,
      helpText: isStart ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
    );

    if (picked != null) {
      if (isStart) {
        ref
            .read(reportPeriodProvider.notifier)
            .update((p) => p.copyWith(start: picked));
      } else {
        ref
            .read(reportPeriodProvider.notifier)
            .update((p) => p.copyWith(end: picked));
      }
    }
  }

  void _setThisMonth(WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    ref.read(reportPeriodProvider.notifier).state =
        ReportPeriod(start: start, end: end);
  }

  void _setLastMonth(WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 1);
    ref.read(reportPeriodProvider.notifier).state =
        ReportPeriod(start: start, end: end);
  }

  void _setThisYear(WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    ref.read(reportPeriodProvider.notifier).state =
        ReportPeriod(start: start, end: end);
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateHelper.format(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      labelStyle: const TextStyle(fontSize: 12),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── KPI cards row ─────────────────────────────────────────────────────────

class _KpiRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final yearTotalAsync = ref.watch(yearlyIncomeTotalProvider);
    final period = ref.watch(reportPeriodProvider);

    return summaryAsync.when(
      loading: () => const _KpiSkeleton(),
      error: (e, _) => Text('خطأ: $e'),
      data: (s) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'الإيراد في الفترة',
                  value: '${s.income.toStringAsFixed(0)} ₺',
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                  sub: yearTotalAsync.maybeWhen(
                    data: (t) => 'سنوي (${period.start.year}): ${t.toStringAsFixed(0)} ₺',
                    orElse: () => '',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: 'المواعيد',
                  value: '${s.appointments}',
                  icon: Icons.calendar_month_outlined,
                  color: Colors.blue,
                  sub: 'في الفترة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'علاجات مكتملة',
                  value: '${s.completedTreatments}',
                  icon: Icons.healing_outlined,
                  color: Colors.teal,
                  sub: 'في الفترة',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: 'مرضى جدد',
                  value: '${s.newPatients}',
                  icon: Icons.person_add_outlined,
                  color: Colors.purple,
                  sub: 'الإجمالي: ${s.totalPatients}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub = '',
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              if (sub.isNotEmpty)
                Text(
                  sub,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Income bar chart ──────────────────────────────────────────────────────

class _IncomeBarChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(yearlyIncomeBreakdownProvider);
    final period = ref.watch(reportPeriodProvider);
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'الإيراد الشهري — ${period.start.year}',
      icon: Icons.bar_chart_outlined,
      child: dataAsync.when(
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('خطأ: $e'),
        data: (months) {
          final maxVal = months.fold<double>(
            0,
            (m, e) => e.total > m ? e.total : m,
          );
          if (maxVal == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'لا توجد بيانات لهذه السنة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          const fullMonthNames = [
            'يناير',
            'فبراير',
            'مارس',
            'أبريل',
            'مايو',
            'يونيو',
            'يوليو',
            'أغسطس',
            'سبتمبر',
            'أكتوبر',
            'نوفمبر',
            'ديسمبر',
          ];

          return SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final ratio = maxVal > 0 ? m.total / maxVal : 0.0;
                // Current is defined as the month of start date IF only one month is selected
                final isCurrent = m.month == period.start.month && 
                                 period.start.year == period.end.year &&
                                 period.start.month == (period.end.month - 1);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (m.total > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              m.total.toStringAsFixed(0),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.outline,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: ratio > 0
                              ? (ratio * 130).clamp(4.0, 130.0)
                              : 4,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Month label (using first letter or short version if full is too long for bar)
                        Text(
                          fullMonthNames[i].substring(0, 2),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// ── Appointments status breakdown ─────────────────────────────────────────

class _AppointmentsBreakdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'توزيع المواعيد',
      icon: Icons.pie_chart_outline,
      child: summaryAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('خطأ: $e'),
        data: (s) {
          final map = s.appointmentsByStatus;
          final total = map.values.fold<int>(0, (a, b) => a + b);

          if (total == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'لا توجد مواعيد في هذه الفترة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          final items = [
            _ApptStatItem(
              'مجدول',
              map['scheduled'] ?? 0,
              theme.colorScheme.primary,
            ),
            _ApptStatItem('مكتمل', map['completed'] ?? 0, Colors.green),
            _ApptStatItem('ملغي', map['cancelled'] ?? 0, Colors.red),
            _ApptStatItem('لم يحضر', map['no_show'] ?? 0, Colors.orange),
          ].where((i) => i.count > 0).toList();

          return Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: items.map((item) {
                      final ratio = item.count / total;
                      return Expanded(
                        flex: (ratio * 1000).round(),
                        child: Container(color: item.color),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: items
                    .map(
                      (item) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.label}: ${item.count}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApptStatItem {
  const _ApptStatItem(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

// ── Top treatments ────────────────────────────────────────────────────────

class _TopTreatmentsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(topTreatmentTypesProvider);
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'أكثر العلاجات شيوعاً',
      icon: Icons.healing_outlined,
      child: dataAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('خطأ: $e'),
        data: (stats) {
          if (stats.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'لا توجد علاجات مكتملة في هذه الفترة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          final maxCount = stats.fold<int>(
            0,
            (m, s) => s.count > m ? s.count : m,
          );

          return Column(
            children: stats.asMap().entries.map((entry) {
              final i = entry.key;
              final stat = entry.value;
              final ratio = maxCount > 0 ? stat.count / maxCount : 0.0;
              final colors = [
                theme.colorScheme.primary,
                Colors.teal,
                Colors.purple,
                Colors.orange,
                Colors.blue,
                Colors.green,
                Colors.red,
                Colors.indigo,
              ];
              final color = colors[i % colors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stat.treatmentType,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${stat.count} — '
                          '${stat.revenue.toStringAsFixed(0)} ₺',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 7,
                        backgroundColor: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
            child,
          ],
        ),
      ),
    );
  }
}
