class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.data,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      data: (json['data'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, value.toString()), // Convert all values to String
      ),
      isRead: json['isRead'] ?? false,
    );
  }

  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isRead;

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'data': data.map(
        (key, value) => MapEntry(key, value.toString()),
      ), // Ensure all values are String
      'isRead': isRead,
    };
  }
}
