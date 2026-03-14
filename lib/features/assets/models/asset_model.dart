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
    return switch (this) {
      AssetFileType.image => Icons.image_outlined,
      AssetFileType.pdf => Icons.picture_as_pdf_outlined,
      AssetFileType.other => Icons.insert_drive_file_outlined,
    };
  }

  Color get color {
    return switch (this) {
      AssetFileType.image => Colors.teal,
      AssetFileType.pdf => Colors.red,
      AssetFileType.other => Colors.blueGrey,
    };
  }

  String get arabicLabel {
    return switch (this) {
      AssetFileType.image => 'صورة',
      AssetFileType.pdf => 'PDF',
      AssetFileType.other => 'ملف',
    };
  }
}

class AssetModel {
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
  final int id;
  final int? patientId;
  final int? treatmentId;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int sizeBytes;
  final String? label;
  final DateTime createdAt;

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
