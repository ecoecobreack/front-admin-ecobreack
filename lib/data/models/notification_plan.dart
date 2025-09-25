import 'package:flutter/foundation.dart';

class AssignedPlanItem {
  final String id;
  final String name;
  final String time;
  final String group;

  AssignedPlanItem({
    required this.id,
    required this.name,
    required this.time,
    required this.group,
  });

  factory AssignedPlanItem.fromJson(Map<String, dynamic> json) {
    return AssignedPlanItem(
      id: json['id'],
      name: json['name'],
      time: json['time'],
      group: json['group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'group': group,
    };
  }
}

class NotificationPlan {
  String id; // Cambiar a no final para permitir actualización
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final Map<DateTime, List<AssignedPlanItem>> assignedPlans;
  final DateTime createdAt;
  bool isActive;
  bool isLoading;

  NotificationPlan({
    this.id = '', // Cambiado a valor por defecto en lugar de requerido
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.assignedPlans,
    DateTime? createdAt,
    this.isActive = true,
    this.isLoading = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    final assignedPlansJson = assignedPlans.map(
      (key, value) => MapEntry(
        key.toIso8601String(),
        value.map((plan) => plan.toJson()).toList(),
      ),
    );

    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'time': time,
      'assignedPlans': assignedPlansJson,
      'isActive': isActive,
    };
  }

  factory NotificationPlan.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationPlan(
        id: json['id'] ?? '', // Asegurarse de capturar el ID
        name: json['name'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        time: json['time'],
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : null,
        isActive: json['isActive'] ?? true,
        assignedPlans: (json['assignedPlans'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            DateTime.parse(key),
            (value as List<dynamic>)
                .map((item) => AssignedPlanItem.fromJson(item))
                .toList(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error parsing NotificationPlan: $e');
      rethrow;
    }
  }
}
