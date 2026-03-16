import 'package:flutter/material.dart';

import 'package:dentix/core/utils/validators.dart';
import 'package:dentix/core/locale/generated/l10n.dart';

class PhoneNumberInput extends StatelessWidget {
  const PhoneNumberInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        enableSuggestions: true,
        controller: controller,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: TextInputType.phone,
        maxLength: 9, // for +963XXXXXXXXX (13 chars max)
        validator: phoneNumberValidator,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        decoration: InputDecoration(
          hintText: S.of(context).writeMobileNumber,
          // hides the default counter if you don’t want it
          counterText: '',
          prefix: const Text('+963 ', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
