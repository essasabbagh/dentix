import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patients_providers.dart';

class PatientSearchBar extends ConsumerStatefulWidget {
  const PatientSearchBar({super.key});

  @override
  ConsumerState<PatientSearchBar> createState() => _PatientSearchBarState();
}

class _PatientSearchBarState extends ConsumerState<PatientSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو رقم الهاتف...',
        hintTextDirection: TextDirection.rtl,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  ref
                      .read(patientSearchQueryProvider.notifier)
                      .state = '';
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() {}); // rebuild for suffix icon
        ref.read(patientSearchQueryProvider.notifier).state = value;
      },
    );
  }
}
