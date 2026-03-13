import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/database/daos/payments_dao.dart';
import '../models/payment_model.dart';
import '../providers/payments_providers.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            _PaymentsHeader(),
            _PaymentsSearchAndFilterBar(),
            _PaymentsActiveFilterChips(),
            _PaymentsSummaryBar(),
            const Divider(height: 1),
            const Expanded(child: _PaymentsList()),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _PaymentsHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(paymentsSummaryProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          Icon(
            Icons.payments_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المدفوعات',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              summary.maybeWhen(
                data: (s) => Text(
                  '${s.count} معاملة',
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

class _PaymentsSearchAndFilterBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PaymentsSearchAndFilterBar> createState() =>
      _PaymentsSearchAndFilterBarState();
}

class _PaymentsSearchAndFilterBarState
    extends ConsumerState<_PaymentsSearchAndFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(paymentsFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث باسم المريض...',
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(paymentsFilterProvider.notifier)
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
                  .read(paymentsFilterProvider.notifier)
                  .update((f) => f.copyWith(query: v)),
            ),
          ),
          const SizedBox(width: 8),
          _FilterIconButton(
            active:
                filter.status != null ||
                filter.method != null ||
                filter.dateFrom != null ||
                filter.dateTo != null,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const _PaymentsFilterSheet(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active filter chips ────────────────────────────────────────────────────

class _PaymentsActiveFilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(paymentsFilterProvider);
    final chips = <Widget>[];

    if (filter.status != null) {
      chips.add(
        _RemovableChip(
          label: filter.status!.arabicLabel,
          onRemove: () => ref
              .read(paymentsFilterProvider.notifier)
              .update((f) => f.copyWith(status: null)),
        ),
      );
    }
    if (filter.method != null) {
      chips.add(
        _RemovableChip(
          label: filter.method!.arabicLabel,
          onRemove: () => ref
              .read(paymentsFilterProvider.notifier)
              .update((f) => f.copyWith(method: null)),
        ),
      );
    }
    if (filter.dateFrom != null) {
      chips.add(
        _RemovableChip(
          label: 'من: ${DateFormat('d/M/yyyy').format(filter.dateFrom!)}',
          onRemove: () => ref
              .read(paymentsFilterProvider.notifier)
              .update((f) => f.copyWith(dateFrom: null)),
        ),
      );
    }
    if (filter.dateTo != null) {
      chips.add(
        _RemovableChip(
          label: 'إلى: ${DateFormat('d/M/yyyy').format(filter.dateTo!)}',
          onRemove: () => ref
              .read(paymentsFilterProvider.notifier)
              .update((f) => f.copyWith(dateTo: null)),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Expanded(child: Wrap(spacing: 6, children: chips)),
          TextButton(
            onPressed: () => ref.read(paymentsFilterProvider.notifier).state =
                const PaymentsFilter(),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}

// ── Summary bar ────────────────────────────────────────────────────────────

class _PaymentsSummaryBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(paymentsSummaryProvider);
    final theme = Theme.of(context);

    return summary.maybeWhen(
      data: (s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: theme.colorScheme.surfaceContainerLowest,
        child: Row(
          children: [
            _StatPill(
              label: 'إجمالي المدفوع',
              value: '${s.totalPaid.toStringAsFixed(0)} ر.س',
              color: Colors.green,
            ),
            const SizedBox(width: 24),
            _StatPill(
              label: 'معلق',
              value: '${s.totalPending.toStringAsFixed(0)} ر.س',
              color: Colors.orange,
            ),
            const Spacer(),
            // Method breakdown chips
            _MethodBreakdown(),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _MethodBreakdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(filteredPaymentsProvider);
    return dataAsync.maybeWhen(
      data: (list) {
        final cash = list
            .where((p) => p.payment.paymentMethod == 'cash')
            .fold<double>(0, (s, p) => s + p.payment.amount);
        final card = list
            .where((p) => p.payment.paymentMethod == 'card')
            .fold<double>(0, (s, p) => s + p.payment.amount);
        final transfer = list
            .where((p) => p.payment.paymentMethod == 'transfer')
            .fold<double>(0, (s, p) => s + p.payment.amount);

        return Row(
          children: [
            if (cash > 0)
              _MiniMethodPill(
                icon: Icons.money_outlined,
                value: cash.toStringAsFixed(0),
                color: Colors.teal,
              ),
            if (card > 0) ...[
              const SizedBox(width: 6),
              _MiniMethodPill(
                icon: Icons.credit_card_outlined,
                value: card.toStringAsFixed(0),
                color: Colors.blue,
              ),
            ],
            if (transfer > 0) ...[
              const SizedBox(width: 6),
              _MiniMethodPill(
                icon: Icons.account_balance_outlined,
                value: transfer.toStringAsFixed(0),
                color: Colors.purple,
              ),
            ],
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _MiniMethodPill extends StatelessWidget {
  const _MiniMethodPill({
    required this.icon,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payments list ──────────────────────────────────────────────────────────

class _PaymentsList extends ConsumerWidget {
  const _PaymentsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(filteredPaymentsProvider);
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
                  Icons.payments_outlined,
                  size: 64,
                  color: theme.colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مدفوعات',
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
          itemBuilder: (_, i) => _PaymentCard(item: items[i]),
        );
      },
    );
  }
}

class _PaymentCard extends ConsumerWidget {
  const _PaymentCard({required this.item});
  final PaymentWithPatient item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final method = PaymentMethod.fromDb(item.payment.paymentMethod);
    final status = PaymentStatus.fromDb(item.payment.paymentStatus);
    final statusColor = _statusColor(status, theme);
    final methodColor = _methodColor(method);

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
            // Method icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: methodColor.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: Icon(_methodIcon(method), size: 20, color: methodColor),
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
                          item.patientFullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Amount
                      Text(
                        '${item.payment.amount.toStringAsFixed(0)} ر.س',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: status == PaymentStatus.paid
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _MethodBadge(
                        label: method.arabicLabel,
                        color: methodColor,
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: status.arabicLabel,
                        color: statusColor,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d/M/yyyy').format(item.payment.paymentDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  if (item.payment.notes?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.payment.notes!,
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
            // Delete
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              onPressed: () => ref
                  .read(paymentFormProvider.notifier)
                  .delete(item.payment.id),
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

  Color _methodColor(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Colors.teal;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.transfer:
        return Colors.purple;
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

// ── Filter bottom sheet ────────────────────────────────────────────────────

class _PaymentsFilterSheet extends ConsumerStatefulWidget {
  const _PaymentsFilterSheet();

  @override
  ConsumerState<_PaymentsFilterSheet> createState() =>
      _PaymentsFilterSheetState();
}

class _PaymentsFilterSheetState extends ConsumerState<_PaymentsFilterSheet> {
  late PaymentStatus? _status;
  late PaymentMethod? _method;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    final f = ref.read(paymentsFilterProvider);
    _status = f.status;
    _method = f.method;
    _dateFrom = f.dateFrom;
    _dateTo = f.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
                'تصفية المدفوعات',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Payment status
              Text(
                'حالة الدفع',
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
                  ...PaymentStatus.values.map(
                    (s) => _SheetChip(
                      label: s.arabicLabel,
                      selected: _status == s,
                      onTap: () => setState(() => _status = s),
                      color: _payStatusColor(s),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment method
              Text(
                'طريقة الدفع',
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
                    selected: _method == null,
                    onTap: () => setState(() => _method = null),
                  ),
                  ...PaymentMethod.values.map(
                    (m) => _SheetChip(
                      label: m.arabicLabel,
                      selected: _method == m,
                      onTap: () => setState(() => _method = m),
                      color: _methodColor(m),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(paymentsFilterProvider.notifier)
                            .update(
                              (f) => f.copyWith(
                                status: null,
                                method: null,
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
                            .read(paymentsFilterProvider.notifier)
                            .update(
                              (f) => f.copyWith(
                                status: _status,
                                method: _method,
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
      ),
    );
  }

  Color _payStatusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.partial:
        return Colors.blue;
    }
  }

  Color _methodColor(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Colors.teal;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.transfer:
        return Colors.purple;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═════════════════════════════════════════════════════════════════════════════

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({required this.active, required this.onTap});
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

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
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
    required this.onTap,
    this.onClear,
  });
  final String label;
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
            Icons.calendar_today_outlined,
            size: 14,
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
