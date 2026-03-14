import 'package:flutter/material.dart';

enum AssetOwner { patient, treatment }

enum AssetFileType {
  image,
  pdf,
  other;

  static AssetFileType fromMime(String mime) {
    if (mime.startsWith('image/')) return AssetFileType.image;
    if (mime == 'application/pdf') return AssetFileType.pdf;
    return AssetFileType.other;
  }

  IconData get icon {
    switch (this) {
      case AssetFileType.image:
        return Icons.image_outlined;
      case AssetFileType.pdf:
        return Icons.picture_as_pdf_outlined;
      case AssetFileType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color get color {
    switch (this) {
      case AssetFileType.image:
        return Colors.teal;
      case AssetFileType.pdf:
        return Colors.red;
      case AssetFileType.other:
        return Colors.blueGrey;
    }
  }

  String get arabicLabel {
    switch (this) {
      case AssetFileType.image:
        return 'صورة';
      case AssetFileType.pdf:
        return 'PDF';
      case AssetFileType.other:
        return 'ملف';
    }
  }
}

class AssetModel {
  final int id;
  final int? patientId;
  final int? treatmentId;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int sizeBytes;
  final String? label;
  final DateTime createdAt;

  const AssetModel({
    required this.id,
    this.patientId,
    this.treatmentId,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.sizeBytes,
    this.label,
    required this.createdAt,
  });

  AssetFileType get fileType => AssetFileType.fromMime(mimeType);

  AssetOwner get owner =>
      patientId != null ? AssetOwner.patient : AssetOwner.treatment;

  /// Human-readable file size  e.g. "1.2 MB"
  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Display name: label if set, else fileName
  String get displayName => label?.isNotEmpty == true ? label! : fileName;
}
