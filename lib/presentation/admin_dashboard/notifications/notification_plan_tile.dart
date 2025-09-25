import 'package:flutter/material.dart';

class NotificationPlanTile extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isTemplate;
  final VoidCallback? onColorTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onMoreTap;

  const NotificationPlanTile({
    super.key,
    required this.plan,
    this.isTemplate = false,
    this.onColorTap,
    this.onDeleteTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(plan['name'] ?? ''),
      subtitle: Text('Hora: ${plan['time'] ?? ''}'),
      leading: Icon(
        Icons.drag_indicator,
        color: plan['color'] ?? const Color(0xFF0067AC),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: onMoreTap,
      ),
      enabled: !(plan['isAssigned'] ?? false),
      onTap: onColorTap,
      onLongPress: onDeleteTap,
    );
  }
}
