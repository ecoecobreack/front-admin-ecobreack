import 'package:flutter/material.dart';

class AvailablePlansList extends StatelessWidget {
  final List<Map<String, dynamic>> availablePlans;
  final Widget Function(Map<String, dynamic> plan, bool isTemplate)
  buildDraggablePlan;

  const AvailablePlansList({
    super.key,
    required this.availablePlans,
    required this.buildDraggablePlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Planes Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: availablePlans.length,
              itemBuilder: (context, index) {
                final plan = availablePlans[index];
                if (plan['isAssigned']) return const SizedBox.shrink();
                return buildDraggablePlan(plan, true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
