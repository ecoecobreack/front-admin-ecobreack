import 'package:flutter/material.dart';
import 'user.dart';

class ProcessGroup {
  final String id;
  final String name;
  final String description;
  final Color color;
  final List<User> members;
  final DateTime createdAt;

  ProcessGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.members,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color':
          '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      'members': members.map((user) => user.id).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProcessGroup.fromJson(Map<String, dynamic> json) {
    return ProcessGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color:
          json['color'] != null
              ? Color(
                int.parse(json['color'].substring(1), radix: 16) | 0xFF000000,
              )
              : const Color.fromARGB(255, 0, 103, 172),
      members:
          (json['members'] as List? ?? [])
              .where(
                (member) => member != null && member is Map<String, dynamic>,
              )
              .map((member) => User.fromJson(member as Map<String, dynamic>))
              .toList(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }
}
