import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:template/features/patients/models/patient_model.dart';
import 'package:template/features/patients/providers/patients_providers.dart';

/// A searchable patient selector.
///
/// - Shows a text field inside the dropdown menu to filter by name or phone.
/// - If [initialPatientId] is provided the matching patient is pre-selected
///   and the field is locked (read-only), which is the right UX when opening
///   "Add Appointment" from inside PatientDetailPage.
/// - When [initialPatientId] is null the field starts empty and the user
///   must pick a patient (normal flow from AppointmentsPage).
class PatientSelectorField extends ConsumerStatefulWidget {
  const PatientSelectorField({
    super.key,
    this.initialPatientId,
    required this.onChanged,
    this.validator,
  });

  /// Pre-select and lock the field to this patient id.
  /// Pass [PatientModel.id] when opening from PatientDetailPage.
  final int? initialPatientId;

  final ValueChanged<PatientModel?> onChanged;
  final String? Function(PatientModel?)? validator;

  @override
  ConsumerState<PatientSelectorField> createState() =>
      _PatientSelectorFieldState();
}

class _PatientSelectorFieldState extends ConsumerState<PatientSelectorField> {
  PatientModel? _selected;

  // True when the field was seeded from initialPatientId — locks editing
  bool get _isLocked => widget.initialPatientId != null;

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsListProvider);

    return patientsAsync.when(
      loading: () => const _LoadingField(),
      error: (e, _) => Text('خطأ في تحميل المرضى: $e'),
      data: (patients) {
        // Seed selection once when list arrives
        if (_selected == null && widget.initialPatientId != null) {
          final match = patients.where(
            (p) => p.id == widget.initialPatientId,
          );
          if (match.isNotEmpty) {
            // Schedule after build to avoid setState-during-build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _selected = match.first);
                widget.onChanged(match.first);
              }
            });
          }
        }

        // Locked view — shown when opened from PatientDetailPage
        if (_isLocked) {
          return _LockedPatientField(patient: _selected);
        }

        // Interactive searchable dropdown
        return _SearchableDropdown(
          patients: patients,
          selected: _selected,
          onChanged: (p) {
            setState(() => _selected = p);
            widget.onChanged(p);
          },
          validator: widget.validator,
        );
      },
    );
  }
}

// ── Locked (read-only) view ───────────────────────────────────────────────

class _LockedPatientField extends StatelessWidget {
  const _LockedPatientField({this.patient});
  final PatientModel? patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: const Icon(Icons.person_outline),
        // Lock icon signals the field is fixed
        suffixIcon: Tooltip(
          message: 'المريض محدد مسبقاً',
          child: Icon(
            Icons.lock_outline,
            size: 18,
            color: theme.colorScheme.outline,
          ),
        ),
      ),
      child: patient == null
          ? Text(
              'جاري التحميل...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          : _PatientTile(patient: patient!),
    );
  }
}

// ── Interactive searchable dropdown ──────────────────────────────────────

class _SearchableDropdown extends StatefulWidget {
  const _SearchableDropdown({
    required this.patients,
    required this.selected,
    required this.onChanged,
    this.validator,
  });

  final List<PatientModel> patients;
  final PatientModel? selected;
  final ValueChanged<PatientModel?> onChanged;
  final String? Function(PatientModel?)? validator;

  @override
  State<_SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<_SearchableDropdown> {
  final _searchController = TextEditingController();
  final _layerLink = LayerLink();
  final _overlayKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<PatientModel> _filtered = [];

  // FormField key so we can trigger validation externally
  final _fieldKey = GlobalKey<FormFieldState<PatientModel>>();

  @override
  void initState() {
    super.initState();
    _filtered = widget.patients;
  }

  @override
  void didUpdateWidget(_SearchableDropdown old) {
    super.didUpdateWidget(old);
    if (old.patients != widget.patients) {
      _applyFilter(_searchController.text);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter ──────────────────────────────────────────────────

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.patients
          : widget.patients.where((p) {
              return p.fullName.toLowerCase().contains(q) ||
                  p.phone.contains(q);
            }).toList();
    });
    // Rebuild overlay with new filtered list
    _overlayEntry?.markNeedsBuild();
  }

  // ── Overlay management ──────────────────────────────────────

  void _open() {
    if (_isOpen) return;
    _searchController.clear();
    _applyFilter('');
    _isOpen = true;
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _close() {
    _removeOverlay();
    setState(() {});
  }

  void _select(PatientModel patient) {
    widget.onChanged(patient);
    _fieldKey.currentState?.didChange(patient);
    _close();
    _searchController.clear();
  }

  OverlayEntry _buildOverlay() {
    // Measure the anchor widget size so the dropdown matches its width
    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 300;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        // Tap outside → close
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 56), // below the anchor field
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: width,
                  child: GestureDetector(
                    // Don't close when tapping inside the dropdown
                    onTap: () {},
                    child: _DropdownContent(
                      searchController: _searchController,
                      patients: _filtered,
                      selected: widget.selected,
                      onSearchChanged: _applyFilter,
                      onSelect: _select,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<PatientModel>(
        key: _fieldKey,
        initialValue: widget.selected,
        validator: widget.validator,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anchor — tap opens the overlay dropdown
            GestureDetector(
              onTap: _isOpen ? _close : _open,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: state.hasError
                        ? BorderSide(color: theme.colorScheme.error, width: 1.5)
                        : BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: state.hasError
                        ? BorderSide(color: theme.colorScheme.error, width: 1.5)
                        : BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.outline,
                  ),
                ),
                child: widget.selected == null
                    ? Text(
                        'اختر المريض',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      )
                    : _PatientTile(patient: widget.selected!),
              ),
            ),
            // Validation error label
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: Text(
                  state.errorText!,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown content (search + list) ─────────────────────────────────────

class _DropdownContent extends StatelessWidget {
  const _DropdownContent({
    required this.searchController,
    required this.patients,
    required this.selected,
    required this.onSearchChanged,
    required this.onSelect,
  });

  final TextEditingController searchController;
  final List<PatientModel> patients;
  final PatientModel? selected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PatientModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search field ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            textDirection: TextDirection.rtl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو الهاتف...',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const Divider(height: 1),
        // ── Results list ────────────────────────────────────
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: patients.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'لا توجد نتائج',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 52),
                  itemBuilder: (_, i) {
                    final patient = patients[i];
                    final isSelected = selected?.id == patient.id;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor:
                          theme.colorScheme.primaryContainer.withOpacity(0.4),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Text(
                          _initials(patient),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      title: Text(
                        patient.fullName,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        patient.phone,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check,
                              size: 16, color: theme.colorScheme.primary)
                          : null,
                      onTap: () => onSelect(patient),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _initials(PatientModel p) {
    final f = p.firstName.isNotEmpty ? p.firstName[0] : '';
    final l = p.lastName.isNotEmpty ? p.lastName[0] : '';
    return '$f$l';
  }
}

// ── Patient tile (selected state display) ─────────────────────────────────

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});
  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            _initials,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                patient.fullName,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                patient.phone,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _initials {
    final f = patient.firstName.isNotEmpty ? patient.firstName[0] : '';
    final l = patient.lastName.isNotEmpty ? patient.lastName[0] : '';
    return '$f$l';
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'جاري التحميل...',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
