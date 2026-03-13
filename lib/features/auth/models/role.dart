import 'pivot.dart';

class Role {
  Role({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['id'],
    name: json['name'],
    guardName: json['guard_name'],
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at']),
    pivot: json['pivot'] == null ? null : Pivot.fromJson(json['pivot']),
  );
  int? id;
  String? name;
  String? guardName;
  DateTime? createdAt;
  DateTime? updatedAt;
  Pivot? pivot;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'guard_name': guardName,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'pivot': pivot?.toJson(),
  };
}
