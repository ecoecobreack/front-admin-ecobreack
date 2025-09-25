class Plan {
  late String id;
  late String name;
  late String groupId;
  late List<String> categories;
  late String estado;
  late DateTime createdAt;
  late DateTime updatedAt;

  toJson() {
    return {
      'id': id,
      'name': name,
      'groupId': groupId,
      'categories': categories,
      'estado': estado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Plan fromJson(Map<String, dynamic> json) {
    Plan plan = Plan();
    plan.id = json['id'] ?? '';
    plan.name = json['nombre'] ?? '';
    plan.groupId = json['groupId'] ?? '';
    plan.categories = (json['categories'] as List? ?? []).cast<String>();
    plan.estado = json['estado'] ?? 'active';
    plan.createdAt =
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now();
    plan.updatedAt =
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now();
    return plan;
  }
}
