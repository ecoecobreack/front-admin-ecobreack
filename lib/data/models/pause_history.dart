class PauseHistory {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final String planId;
  final String planName;
  final int duration;
  final double completionRate;

  PauseHistory({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.planId,
    required this.planName,
    required this.duration,
    required this.completionRate,
  });

  factory PauseHistory.fromJson(Map<String, dynamic> json) {
    return PauseHistory(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      date: DateTime.parse(json['date']),
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      duration: json['duration'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'date': date.toIso8601String(),
    'planId': planId,
    'planName': planName,
    'duration': duration,
    'completionRate': completionRate,
  };
}
