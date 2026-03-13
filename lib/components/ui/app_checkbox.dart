import 'package:flutter/material.dart';

import 'package:template/core/themes/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.title,
    this.value,
    this.onChanged,
  });

  final String title;
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      splashRadius: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      checkColor: AppColors.white,
      activeColor: AppColors.primaryColor,
      side: const BorderSide(
        color: AppColors.gray500,
        width: 2,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
