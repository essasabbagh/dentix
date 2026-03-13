class Pivot {
  Pivot({this.modelId, this.roleId, this.modelType});

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    modelId: json['model_id'],
    roleId: json['role_id'],
    modelType: json['model_type'],
  );
  int? modelId;
  int? roleId;
  String? modelType;

  Map<String, dynamic> toJson() => {
    'model_id': modelId,
    'role_id': roleId,
    'model_type': modelType,
  };
}
