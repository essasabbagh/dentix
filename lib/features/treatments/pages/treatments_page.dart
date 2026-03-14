import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/database/daos/treatments_dao.dart';
import '../models/treatment_model.dart';
import '../providers/treatments_providers.dart';

class TreatmentsPage extends ConsumerWidget {
  const TreatmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _TreatmentsHeader(),
          _SearchAndFilterBar(),
          _ActiveFilterChips(),
          _SummaryBar(),
          const Divider(height: 1),
          const Expanded(child: _TreatmentsList()),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _TreatmentsHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(treatmentsSummaryProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          Icon(
            Icons.healing_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'العلاجات',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              summary.maybeWhen(
                data: (s) => Text(
                  '${s.count} علاج',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Search + filter bar ────────────────────────────────────────────────────

class _SearchAndFilterBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchAndFilterBar> createState() =>
      _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends ConsumerState<_SearchAndFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(treatmentsFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث بالمريض أو نوع العلاج...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(treatmentsFilterProvider.notifier)
                              .update((f) => f.copyWith(query: ''));
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => ref
                  .read(treatmentsFilterProvider.notifier)
                  .update((f) => f.copyWith(query: v)),
            ),
          ),
          const SizedBox(width: 8),
          // Filter button
          _FilterButton(
            active: filter.hasActiveFilters && filter.query.isEmpty
                ? filter.status != null ||
                      filter.dateFrom != null ||
                      filter.dateTo != null
                : false,
            onTap: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _TreatmentsFilterSheet(),
    );
  }
}

// ── Active filter chips ────────────────────────────────────────────────────

class _ActiveFilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(treatmentsFilterProvider);
    final chips = <Widget>[];

    if (filter.status != null) {
      chips.add(
        _FilterChip(
          label: filter.status!.arabicLabel,
          onRemove: () => ref
              .read(treatmentsFilterProvider.notifier)
              .update((f) => f.copyWith(status: null)),
        ),
      );
    }
    if (filter.dateFrom != null) {
      chips.add(
        _FilterChip(
          label: 'من: ${DateFormat('d/M/yyyy').format(filter.dateFrom!)}',
          onRemove: () => ref
              .read(treatmentsFilterProvider.notifier)
              .update((f) => f.copyWith(dateFrom: null)),
        ),
      );
    }
    if (filter.dateTo != null) {
      chips.add(
        _FilterChip(
          label: 'إلى: ${DateFormat('d/M/yyyy').format(filter.dateTo!)}',
          onRemove: () => ref
              .read(treatmentsFilterProvider.notifier)
              .update((f) => f.copyWith(dateTo: null)),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Wrap(spacing: 6, children: chips),
          ),
          TextButton(
            onPressed: () => ref.read(treatmentsFilterProvider.notifier).state =
                const TreatmentsFilter(),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}

// ── Summary stats bar ──────────────────────────────────────────────────────

class _SummaryBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(treatmentsSummaryProvider);
    final theme = Theme.of(context);

    return summary.maybeWhen(
      data: (s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: theme.colorScheme.surfaceContainerLowest,
        child: Row(
          children: [
            _StatPill(
              label: 'الإجمالي',
              value: '${s.total.toStringAsFixed(0)} ر.س',
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 20),
            _StatPill(
              label: 'مكتمل',
              value: '${s.completed.toStringAsFixed(0)} ر.س',
              color: Colors.green,
            ),
            const SizedBox(width: 20),
            _StatPill(
              label: 'متبقي',
              value: '${(s.total - s.completed).toStringAsFixed(0)} ر.س',
              color: Colors.orange,
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── Treatments list ────────────────────────────────────────────────────────

class _TreatmentsList extends ConsumerWidget {
  const _TreatmentsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(filteredTreatmentsProvider);
    final theme = Theme.of(context);

    return dataAsync.maybeWhen(
      loading: () => const Center(child: CircularProgressIndicator()),
      orElse: () => const Center(child: Text('حدث خطأ')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.healing_outlined,
                  size: 64,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد علاجات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _TreatmentCard(item: items[i]),
        );
      },
    );
  }
}

class _TreatmentCard extends ConsumerWidget {
  const _TreatmentCard({required this.item});
  final TreatmentWithPatient item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = TreatmentStatus.fromDb(item.treatment.status);
    final statusColor = _statusColor(status, theme);

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
            // Status indicator bar
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.treatment.treatmentType,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${item.treatment.price.toStringAsFixed(0)} ر.س',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 13,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.patientFullName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      if (item.treatment.toothNumber != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.circle,
                          size: 4,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'سن ${item.treatment.toothNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        DateFormat('d/M/yyyy').format(item.treatment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (item.treatment.notes?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.treatment.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outlineVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Status badge + actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(label: status.arabicLabel, color: statusColor),
                const SizedBox(height: 6),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (_) => [
                    if (status != TreatmentStatus.completed)
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
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
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
                          .complete(item.treatment.id);
                    } else if (v == 'delete') {
                      ref
                          .read(treatmentFormProvider.notifier)
                          .delete(item.treatment.id);
                    }
                  },
                ),
              ],
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

// ── Filter bottom sheet ────────────────────────────────────────────────────

class _TreatmentsFilterSheet extends ConsumerStatefulWidget {
  const _TreatmentsFilterSheet();

  @override
  ConsumerState<_TreatmentsFilterSheet> createState() =>
      _TreatmentsFilterSheetState();
}

class _TreatmentsFilterSheetState
    extends ConsumerState<_TreatmentsFilterSheet> {
  late TreatmentStatus? _status;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    final f = ref.read(treatmentsFilterProvider);
    _status = f.status;
    _dateFrom = f.dateFrom;
    _dateTo = f.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet handle + title
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تصفية العلاجات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Status filter
            Text(
              'الحالة',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _SheetChip(
                  label: 'الكل',
                  selected: _status == null,
                  onTap: () => setState(() => _status = null),
                ),
                ...TreatmentStatus.values.map(
                  (s) => _SheetChip(
                    label: s.arabicLabel,
                    selected: _status == s,
                    onTap: () => setState(() => _status = s),
                    color: _statusColor(s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date range
            Text(
              'نطاق التاريخ',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: _dateFrom != null
                        ? DateFormat('d/M/yyyy').format(_dateFrom!)
                        : 'من تاريخ',
                    icon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dateFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('ar'),
                      );
                      if (d != null) setState(() => _dateFrom = d);
                    },
                    onClear: _dateFrom != null
                        ? () => setState(() => _dateFrom = null)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DatePickerButton(
                    label: _dateTo != null
                        ? DateFormat('d/M/yyyy').format(_dateTo!)
                        : 'إلى تاريخ',
                    icon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dateTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('ar'),
                      );
                      if (d != null) setState(() => _dateTo = d);
                    },
                    onClear: _dateTo != null
                        ? () => setState(() => _dateTo = null)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply / Reset
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(treatmentsFilterProvider.notifier)
                          .update(
                            (f) => f.copyWith(
                              status: null,
                              dateFrom: null,
                              dateTo: null,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('إعادة تعيين'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref
                          .read(treatmentsFilterProvider.notifier)
                          .update(
                            (f) => f.copyWith(
                              status: _status,
                              dateFrom: _dateFrom,
                              dateTo: _dateTo,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TreatmentStatus s) {
    switch (s) {
      case TreatmentStatus.planned:
        return Colors.blue;
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
// Shared small widgets
// ═════════════════════════════════════════════════════════════════════════════

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.tune),
          onPressed: onTap,
          style: IconButton.styleFrom(
            side: BorderSide(
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
        ),
        if (active)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: theme.colorScheme.onPrimaryContainer,
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
        color: color.withValues(alpha: .12),
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
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
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? c : theme.colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? c : theme.colorScheme.outline,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.onClear,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = onClear != null;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        side: BorderSide(
          color: hasValue
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: hasValue
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: hasValue
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
