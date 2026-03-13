import 'package:flutter/material.dart';

class BaseDropdown<T> extends StatelessWidget {
  const BaseDropdown({
    super.key,
    this.items,
    this.selectedItemBuilder,
    this.value,
    this.onChanged,
    this.validator,
    this.hint,
  });

  final List<DropdownMenuItem<T>>? items;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? hint;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      child: DropdownButtonFormField<T>(
        elevation: 2,
        iconSize: 32,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        borderRadius: BorderRadius.circular(12.0),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        hint: hint,
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
