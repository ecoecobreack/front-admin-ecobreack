import 'package:flutter/material.dart';
import '../../../../../core/services/serv_actividades/activity_service.dart';

class PlanDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> plan;

  const PlanDetailsDialog({super.key, required this.plan});

  @override
  State<PlanDetailsDialog> createState() => _PlanDetailsDialogState();
}

class _PlanDetailsDialogState extends State<PlanDetailsDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPlanActivities();
  }

  Future<void> _loadPlanActivities() async {
    try {
      setState(() => _isLoading = true);


      // Obtener los IDs de las actividades del plan
      final planActivities = List<Map<String, dynamic>>.from(
        widget.plan['ejercicios'] ?? [],
      );

      // Mapear las actividades del plan con sus detalles completos


      if (mounted) {
        setState(() {
          _activities = planActivities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        child: Container(
          width: 800,
          height: 400,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Dialog(
        child: Container(
          width: 800,
          height: 400,
          alignment: Alignment.center,
          child: Text('Error: $_error'),
        ),
      );
    }

    final totalDuration = _activities.fold<int>(
      0,
      (sum, activity) => sum + (activity['duracion'] as int? ?? 0),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanInfo(),
                    const SizedBox(height: 24),
                    _buildActivitiesList(_activities),
                  ],
                ),
              ),
            ),
            _buildFooter(context, totalDuration, _activities.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0067AC).withAlpha(5),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF0067AC).withAlpha(20)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.playlist_play, color: Color(0xFF0067AC), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                  ),
                ),
                Text(
                  'Creado el ${_formatDate(widget.plan['createdAt'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cerrar',
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0067AC).withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.plan['descripcion'] ?? 'Sin descripción',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividades del Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
        const SizedBox(height: 16),
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return _buildActivityItem(activity, index);
        }),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0067AC).withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0067AC).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF0067AC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  activity['descripcion'] ?? 'Sin Descripción',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0067AC).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${activity['duracion']} segundos',
              style: const TextStyle(
                color: Color(0xFF0067AC),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    int totalDuration,
    int activityCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFF0067AC).withAlpha(20)),
        ),
      ),
      child: Row(
        children: [
          _buildInfoBadge(
            icon: Icons.timer,
            label: 'Duración Total',
            value: '${totalDuration ~/ 60} minutos',
          ),
          const SizedBox(width: 24),
          _buildInfoBadge(
            icon: Icons.fitness_center,
            label: 'Actividades',
            value: '$activityCount ejercicios',
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0067AC).withAlpha(5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0067AC).withAlpha(20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0067AC), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0067AC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Fecha desconocida';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Fecha inválida';
    return '${date.day}/${date.month}/${date.year}';
  }
}
