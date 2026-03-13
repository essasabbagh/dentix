import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:template/core/locale/generated/l10n.dart';
import 'package:template/core/utils/snackbars.dart';

class AttachmentField extends StatefulWidget {
  const AttachmentField({
    super.key,
    required this.onPick,
    this.isRequired = false,
    this.initialFile,
  });

  final void Function(File? file) onPick;
  final bool isRequired;
  final File? initialFile;

  @override
  State<AttachmentField> createState() => _AttachmentFieldState();
}

class _AttachmentFieldState extends State<AttachmentField> {
  File? _selectedFile;
  // final TextEditingController _controller = TextEditingController();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
    _controller = TextEditingController(
      text: widget.initialFile?.path.split('/').last ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedFile = file;
          _controller.text = result.files.single.name;
        });
        widget.onPick(file);
      } else {
        setState(() {
          _selectedFile = null;
          _controller.clear();
        });
        widget.onPick(null);
      }
    } catch (e) {
      AppSnackBar.error(S.current.cantPickThisFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.attach_file),
        hintText: S.of(context).selectFile,
      ),
      validator: (val) {
        if (widget.isRequired &&
            (_selectedFile == null || val == null || val.isEmpty)) {
          return S.of(context).required;
        }
        return null;
      },
      onTap: () => _pickFile(context),
    );
  }
}
