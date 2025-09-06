class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String type; // 'immediate' | 'scheduled'
  final bool isActive;
  final List<String>? targetUsers;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.scheduledFor,
    required this.type,
    this.isActive = true,
    this.targetUsers,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      scheduledFor: json['scheduledFor'] != null ? DateTime.parse(json['scheduledFor']) : null,
      type: json['type'] ?? 'immediate',
      isActive: json['isActive'] ?? true,
      targetUsers: json['targetUsers'] != null ? List<String>.from(json['targetUsers']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'scheduledFor': scheduledFor?.toIso8601String(),
    'type': type,
    'isActive': isActive,
    'targetUsers': targetUsers,
  };
}
