import 'package:flutter/material.dart';

enum ToothCondition {
  healthy,
  decay,
  missing,
  filled,
  crown,
  implant,
  rootCanal;

  String get arabicLabel {
    switch (this) {
      case ToothCondition.healthy:
        return 'سليم';
      case ToothCondition.decay:
        return 'تسوس';
      case ToothCondition.missing:
        return 'مفقود';
      case ToothCondition.filled:
        return 'حشوة';
      case ToothCondition.crown:
        return 'تاج';
      case ToothCondition.implant:
        return 'زرعة';
      case ToothCondition.rootCanal:
        return 'علاج عصب';
    }
  }

  String get dbValue {
    switch (this) {
      case ToothCondition.healthy:
        return 'healthy';
      case ToothCondition.decay:
        return 'decay';
      case ToothCondition.missing:
        return 'missing';
      case ToothCondition.filled:
        return 'filled';
      case ToothCondition.crown:
        return 'crown';
      case ToothCondition.implant:
        return 'implant';
      case ToothCondition.rootCanal:
        return 'root_canal';
    }
  }

  /// Color used to colorize the tooth in TeethSelector
  Color get color {
    switch (this) {
      case ToothCondition.healthy:
        return Colors.grey.shade300; // default unselected — handled by widget
      case ToothCondition.decay:
        return Colors.red.shade400;
      case ToothCondition.missing:
        return Colors.grey.shade600;
      case ToothCondition.filled:
        return Colors.blue.shade300;
      case ToothCondition.crown:
        return Colors.amber.shade400;
      case ToothCondition.implant:
        return Colors.purple.shade300;
      case ToothCondition.rootCanal:
        return Colors.orange.shade400;
    }
  }

  Color get strokeColor {
    switch (this) {
      case ToothCondition.missing:
        return Colors.red.shade700;
      case ToothCondition.rootCanal:
        return Colors.orange.shade700;
      default:
        return Colors.transparent;
    }
  }

  static ToothCondition fromDb(String value) {
    switch (value) {
      case 'decay':
        return ToothCondition.decay;
      case 'missing':
        return ToothCondition.missing;
      case 'filled':
        return ToothCondition.filled;
      case 'crown':
        return ToothCondition.crown;
      case 'implant':
        return ToothCondition.implant;
      case 'root_canal':
        return ToothCondition.rootCanal;
      default:
        return ToothCondition.healthy;
    }
  }
}

/// Domain model for one tooth record in the odontogram table
class ToothRecord {
  const ToothRecord({
    required this.id,
    required this.patientId,
    required this.toothNumber,
    required this.condition,
    this.treatmentType,
    this.notes,
    required this.updatedAt,
  });
  final int id;
  final int patientId;
  final int toothNumber;
  final ToothCondition condition;
  final String? treatmentType;
  final String? notes;
  final DateTime updatedAt;

  /// ISO notation string used as key in TeethSelector  (e.g. "11", "48")
  String get isoKey => toothNumber.toString();
}
