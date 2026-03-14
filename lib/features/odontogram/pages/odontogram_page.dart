import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/core/teeth_selector/teeth_selector.dart';

import '../models/tooth_record.dart';
import '../providers/odontogram_providers.dart';

class OdontogramPage extends ConsumerWidget {
  const OdontogramPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final int patientId;
  final String patientName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorMap = ref.watch(teethColorMapProvider(patientId));
    final strokeMap = ref.watch(teethStrokeColorMapProvider(patientId));
    final recordMap = ref.watch(teethRecordMapProvider(patientId));
    final selectedTooth = ref.watch(selectedToothProvider);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('رسم الأسنان — $patientName'),
        ),
        body: Row(
          children: [
            // ── Left panel: TeethSelector ──────────────────────
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Legend
                  _ConditionLegend(),
                  const Divider(height: 1),
                  // The actual SVG teeth widget
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TeethSelector(
                        multiSelect: false,
                        unselectedColor: Colors.grey.shade200,
                        selectedColor: theme.colorScheme.primary,
                        colorized: colorMap,
                        strokedColorized: strokeMap,
                        defaultStrokeColor: Colors.grey.shade400,
                        defaultStrokeWidth: 1,
                        showPermanent: true,
                        showPrimary: false,
                        leftString: 'يسار',
                        rightString: 'يمين',
                        notation: _isoToArabic,
                        onChange: (selected) {
                          // TeethSelector returns selected list.
                          // We only care about the last tapped tooth.
                          final tapped = selected.isEmpty
                              ? null
                              : selected.last;
                          ref.read(selectedToothProvider.notifier).state =
                              tapped;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Right panel: tooth detail / condition picker ───
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: selectedTooth == null
                  ? _NoSelectionPanel()
                  : _ToothDetailPanel(
                      isoKey: selectedTooth,
                      patientId: patientId,
                      existing: recordMap[selectedTooth],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts ISO number to Arabic FDI label shown in tooltip
  String _isoToArabic(String iso) {
    final n = int.tryParse(iso);
    if (n == null) return iso;
    // FDI quadrant label
    final quadrant = n ~/ 10;
    final tooth = n % 10;
    const qLabel = {1: 'ع١', 2: 'ع٢', 3: 'ع٣', 4: 'ع٤'};
    return '${qLabel[quadrant] ?? ''} — سن $tooth\n(ISO: $iso)';
  }
}

// ── No-selection placeholder ──────────────────────────────────────────────

class _NoSelectionPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'اضغط على أي سن لعرض تفاصيله أو تعديل حالته',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tooth detail + condition picker panel ─────────────────────────────────

class _ToothDetailPanel extends ConsumerStatefulWidget {
  const _ToothDetailPanel({
    required this.isoKey,
    required this.patientId,
    this.existing,
  });
  final String isoKey;
  final int patientId;
  final ToothRecord? existing;

  @override
  ConsumerState<_ToothDetailPanel> createState() => _ToothDetailPanelState();
}

class _ToothDetailPanelState extends ConsumerState<_ToothDetailPanel> {
  late ToothCondition _condition;
  late TextEditingController _treatmentController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _condition = widget.existing?.condition ?? ToothCondition.healthy;
    _treatmentController = TextEditingController(
      text: widget.existing?.treatmentType ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );
  }

  @override
  void didUpdateWidget(_ToothDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isoKey != widget.isoKey) {
      _condition = widget.existing?.condition ?? ToothCondition.healthy;
      _treatmentController.text = widget.existing?.treatmentType ?? '';
      _notesController.text = widget.existing?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.watch(odontogramNotifierProvider(widget.patientId));
    final isLoading = notifier.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tooth number header ───────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _condition.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.isoKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السن ${widget.isoKey}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _condition.arabicLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Condition picker ──────────────────────────
          Text(
            'الحالة',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ToothCondition.values.map((c) {
              final isSelected = _condition == c;
              return GestureDetector(
                onTap: () => setState(() => _condition = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? c.color.withValues(alpha: 0.9)
                        : c.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? c.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c.arabicLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Treatment type ────────────────────────────
          TextField(
            controller: _treatmentController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'نوع العلاج',
              hintText: 'مثال: حشوة مركبة',
              prefixIcon: const Icon(Icons.medical_services_outlined, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Notes ─────────────────────────────────────
          TextField(
            controller: _notesController,
            textDirection: TextDirection.rtl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'ملاحظات',
              prefixIcon: const Icon(Icons.notes_outlined, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Action buttons ────────────────────────────
          Row(
            children: [
              // Reset to healthy
              if (widget.existing != null)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(
                                  odontogramNotifierProvider(
                                    widget.patientId,
                                  ).notifier,
                                )
                                .resetTooth(int.parse(widget.isoKey));
                            ref.read(selectedToothProvider.notifier).state =
                                null;
                          },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('إعادة تعيين'),
                  ),
                ),
              if (widget.existing != null) const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _save,
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(odontogramNotifierProvider(widget.patientId).notifier)
        .setCondition(
          toothNumber: int.parse(widget.isoKey),
          condition: _condition,
          treatmentType: _treatmentController.text.trim().isEmpty
              ? null
              : _treatmentController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ حالة السن'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ── Legend bar ────────────────────────────────────────────────────────────

class _ConditionLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: ToothCondition.values
            .where((c) => c != ToothCondition.healthy)
            .map(
              (c) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    c.arabicLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
