import 'package:flutter/material.dart';

class SyncedPlansSection extends StatelessWidget {
  final VoidCallback onReload;
  final List<dynamic> availablePlans;

  const SyncedPlansSection({
    Key? key,
    required this.onReload,
    required this.availablePlans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planes de Pausa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onReload,
                color: const Color(0xFF0067AC),
              ),
            ],
          ),
          if (availablePlans.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No hay planes disponibles',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
