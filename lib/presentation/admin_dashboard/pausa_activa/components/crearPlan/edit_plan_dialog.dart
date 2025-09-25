import 'package:flutter/material.dart';
import '../../../../../core/services/serv_actividades/plan_service.dart';
import '../../../../../core/services/serv_actividades/activity_service.dart';

class EditPlanDialog extends StatefulWidget {
  final Map<String, dynamic> plan;

  const EditPlanDialog({super.key, required this.plan});

  @override
  State<EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends State<EditPlanDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _availableActivities = [];
  List<Map<String, dynamic>> _selectedActivities = [];
  bool _isLoading = true;
  Color _selectedColor = const Color(0xFF4FC3F7); // Valor inicial
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);

      // Cargar datos del plan actual
      _nameController.text = widget.plan['nombre'] ?? '';
      _descriptionController.text = widget.plan['descripcion'] ?? '';
      _selectedActivities =
          widget.plan['ejercicios'] != null
              ? List<Map<String, dynamic>>.from(widget.plan['ejercicios'])
              : [];

      // Inicializa el color del plan
      final colorValue = widget.plan['color'];
      setState(() {
        _selectedColor =
            colorValue != null
                ? Color(colorValue)
                : const Color(0xFF4FC3F7); // Valor por defecto
      });

      // Obtener actividades completas
      final activities = await ActivityService.getActivities();
      final selectedActivityIds = List<String>.from(
        widget.plan['ejercicios']?.map((a) => a['id'] ?? a['id']) ?? [],
      );

      // Filtrar actividades seleccionadas
      final selectedActivities =
          activities
              .where((activity) => selectedActivityIds.contains(activity['id']))
              .toList();

      if (mounted) {
        setState(() {
          _availableActivities =
              activities
                  .where(
                    (activity) => !selectedActivityIds.contains(activity['id']),
                  )
                  .toList();
          _selectedActivities = selectedActivities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        });
      }
    }
  }

  Future<void> _savePlan() async {
    try {
      if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
        throw Exception('Por favor complete todos los campos');
      }

      if (_selectedActivities.isEmpty) {
        throw Exception('El plan debe tener al menos una actividad');
      }

      final updatedPlan = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'color': _selectedColor.value,
        'status': widget.plan['status'],
        'ejercicios':
            _selectedActivities
                .asMap()
                .entries
                .map(
                  (entry) => {
                    'actividadId': entry.value['id'],
                    'order': entry.key,
                  },
                )
                .toList(),
      };

      await PlanService.updatePlan(id: widget.plan['id'], plan: updatedPlan);

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Plan actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDraggableActivitiesList() {
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Actividades Disponibles',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0067AC),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _availableActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _availableActivities[index];
                      final categoryColor = _getCategoryColor(
                        activity['icono'],
                      );

                      return Draggable<Map<String, dynamic>>(
                        data: activity,
                        feedback: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: categoryColor.withAlpha(50),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withAlpha(50),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getCategoryIcon(activity['icono']),
                                color: categoryColor,
                              ),
                              title: Text(
                                activity['nombre'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                ),
                              ),
                              subtitle: Text(
                                activity['descripcion'] ?? '',
                                style: TextStyle(color: categoryColor),
                              ),
                            ),
                          ),
                        ),
                        child: _buildActivityCard(activity),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0067AC).withAlpha(10),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.playlist_play, color: Color(0xFF0067AC)),
                      SizedBox(width: 8),
                      Text(
                        'Actividades del Plan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DragTarget<Map<String, dynamic>>(
                    onAcceptWithDetails: (details) {
                      final data = details.data;
                      setState(() {
                        if (!_selectedActivities.contains(data)) {
                          _selectedActivities.add(data);
                        }
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              candidateData.isNotEmpty
                                  ? const Color.fromARGB(
                                    255,
                                    49,
                                    172,
                                    0,
                                  ).withAlpha(20)
                                  : null,
                        ),
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _selectedActivities.length,
                          itemBuilder: (context, index) {
                            final activity = _selectedActivities[index];
                            final categoryColor = _getCategoryColor(
                              activity['icono'],
                            );

                            return Card(
                              key: ObjectKey('${activity['id']}_$index'),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: categoryColor.withAlpha(50),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: categoryColor.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          49,
                                          172,
                                          0,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  activity['nombre'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromARGB(
                                      255,
                                      49,
                                      172,
                                      0,
                                    ),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['sensorEnabled']
                                          ? 'Sensor Activado'
                                          : 'Sensor Desactivado',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          49,
                                          172,
                                          0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${activity['duracion']} segundos',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      _selectedActivities.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final item = _selectedActivities.removeAt(
                                oldIndex,
                              );
                              _selectedActivities.insert(newIndex, item);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final categoryColor = _getCategoryColor(activity['icono']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: categoryColor.withAlpha(50)),
      ),
      child: _buildActivityTile(activity),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final categoryColor = _getCategoryColor(activity['icono']);

    return ListTile(
      leading: Icon(_getCategoryIcon(activity['icono']), color: categoryColor),
      title: Text(
        activity['nombre'] ?? '',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity['sensorEnabled']
                ? 'Sensor Activado'
                : 'Sensor Desactivado',
            style: TextStyle(color: categoryColor),
          ),
          Text(
            '${activity['duracion']} segundos',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'visual':
        return const Color(0xFF0067AC);
      case 'auditiva':
        return Colors.purple;
      case 'cognitiva':
        return Colors.green;
      case 'tren superior':
        return Colors.blue;
      case 'tren inferior':
        return Colors.orange;
      case 'movilidad articular':
        return Colors.teal;
      default:
        return const Color(0xFF0067AC);
    }
  }

  IconData _getCategoryIcon(String category) {
    // El string viene como "Icons.psychology", extraemos el nombre del icono
    final iconName = category.split('.').last;

    switch (iconName) {
      case 'visibility':
        return Icons.visibility;
      case 'hearing':
        return Icons.hearing;
      case 'psychology':
        return Icons.psychology;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0067AC).withAlpha(20),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0067AC).withAlpha(5),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF0067AC).withAlpha(20),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF0067AC), size: 28),
                  const SizedBox(width: 16),
                  const Text(
                    'Editar Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0067AC),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campos de texto estilizados
                            _buildStyledTextField(
                              controller: _nameController,
                              label: 'Nombre del Plan',
                              hint: 'Ingrese el nombre del plan',
                            ),
                            const SizedBox(height: 24),
                            _buildStyledTextField(
                              controller: _descriptionController,
                              label: 'Descripción',
                              hint:
                                  'Describa el propósito y objetivos del plan',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 24),
                            // Campo para cambiar el estado del plan
                            Row(
                              children: [
                                const Text(
                                  'Estado:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0067AC),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                DropdownButton<String>(
                                  value:
                                      widget.plan['status'] == true
                                          ? 'active'
                                          : 'inactive',
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'active',
                                      child: Text('Activo'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'inactive',
                                      child: Text('Inactivo'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      widget.plan['status'] = value == 'active';
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(height: 24),
                            // Panel de actividades
                            Container(
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF0067AC).withAlpha(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0067AC,
                                    ).withAlpha(10),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildActivitiesHeader(),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child:
                                              _buildDraggableActivitiesList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: const Color(0xFF0067AC).withAlpha(20)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _savePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0067AC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0067AC).withAlpha(5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF0067AC).withAlpha(20)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFF0067AC)),
          const SizedBox(width: 12),
          const Text(
            'Actividades del Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0067AC).withAlpha(10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Duración Total: ${_calculateTotalDuration()}',
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

  String _calculateTotalDuration() {
    final totalSeconds = _selectedActivities.fold<int>(
      0,
      (sum, activity) => sum + ((activity['duracion'] ?? 0) as int),
    );

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes == 0) {
      return '$totalSeconds segundos';
    } else if (seconds == 0) {
      return '$minutes minutos';
    } else {
      return '$minutes min $seconds seg';
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFF0067AC).withAlpha(20),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0067AC), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
