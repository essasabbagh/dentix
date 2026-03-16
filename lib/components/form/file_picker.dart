import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:dentix/core/themes/app_colors.dart';

import '../ui/dotted_border_container.dart';

class FilePickerWidget extends StatefulWidget {
  const FilePickerWidget({
    super.key,
    required this.onPick,
    required this.remove,
    required this.allowedExtensions,
    required this.text,
    required this.supportedFormats,
    required this.isVideo,
    this.initialFile,
  });

  final ValueChanged<File> onPick;
  final VoidCallback remove;
  final List<String>? allowedExtensions;
  final String text;
  final String supportedFormats;
  final bool isVideo;
  final File? initialFile;

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _pickedFile = widget.initialFile;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = File(result.files.first.path!);
      });
      widget.onPick(_pickedFile!);
    }
  }

  void _removeFile() {
    setState(() {
      _pickedFile = null;
    });
    widget.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: DottedBorderContainer(
        radius: 12,
        color: AppColors.textHint,
        strokeWidth: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: _pickedFile == null
                ? _buildEmptyState()
                : _buildFilePreview(_pickedFile!),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text(
          widget.text,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Text(
          widget.supportedFormats,
          style: const TextStyle(color: AppColors.textHint, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFilePreview(File file) {
    return Stack(
      children: [
        widget.isVideo
            ? Container(
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.insert_drive_file,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: _removeFile,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
