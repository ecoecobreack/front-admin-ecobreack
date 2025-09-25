import 'package:flutter/material.dart';
import '../../../core/services/serv_actividades/activity_service.dart';
import 'components/crearActividad/edit_activity_dialog.dart';

class EditActivitiesContent extends StatefulWidget {
  const EditActivitiesContent({super.key});

  @override
  State<EditActivitiesContent> createState() => _EditActivitiesContentState();
}

class _EditActivitiesContentState extends State<EditActivitiesContent> {
  List<Map<String, dynamic>> _activities = [];
  Set<String> _selectedActivities = {};
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      debugPrint('🔄 Cargando actividades...');
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final activities = await ActivityService.getActivities();

      if (!mounted) return;

      setState(() {
        _activities = activities;
        _isLoading = false;
      });

      debugPrint('✅ Actividades cargadas: ${_activities.length}');
    } catch (e) {
      debugPrint('❌ Error cargando actividades: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Error cargando actividades: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelectedActivities() async {
    if (_selectedActivities.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación múltiple'),
            content: Text(
              '¿Está seguro de eliminar ${_selectedActivities.length} actividades?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        for (final activityId in _selectedActivities) {
          await ActivityService.deleteActivity(activityId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actividades eliminadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedActivities.clear();
          _selectAll = false;
        });
        _loadActivities();
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0067AC)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    final filteredActivities =
        _activities
            .where(
              (activity) =>
                  activity['nombre'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  activity['category'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Cambiado a fondo blanco
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0067AC).withAlpha(15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Actividades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                    fontFamily: 'HelveticaRounded',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_activities.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0067AC).withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _selectAll,
                              activeColor: const Color(0xFF0067AC),
                              onChanged: (value) {
                                setState(() {
                                  _selectAll = value ?? false;
                                  if (_selectAll) {
                                    _selectedActivities =
                                        _activities
                                            .map((e) => e['id'] as String)
                                            .toSet();
                                  } else {
                                    _selectedActivities.clear();
                                  }
                                });
                              },
                            ),
                            const Text(
                              'Seleccionar todo',
                              style: TextStyle(
                                color: Color(0xFF0067AC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (_selectedActivities.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade500],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _deleteSelectedActivities,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: Text(
                            'Eliminar (${_selectedActivities.length})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      width: 300,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0067AC).withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar actividad...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF0067AC).withAlpha(150),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child:
                filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];
                        final isSelected = _selectedActivities.contains(
                          activity['id'],
                        );
                        return _buildActivityCard(activity, isSelected);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: const Color(0xFF0067AC).withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay actividades disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0067AC),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva actividad para empezar',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, bool isSelected) {
    // Definir colores por categoría
    Color getCardColor(String category) {
      // recortar "Icons."
      switch (category) {
        case 'Icons.visibility':
          return const Color(0xFF4FC3F7); // Azul claro (Visual)
        case 'Icons.hearing':
          return const Color(0xFF9575CD); // Morado (Auditiva)
        case 'Icons.psychology':
          return const Color(0xFFFFB74D); // Naranja (Cognitiva)
        case 'Icons.accessibility_new':
          return const Color(0xFF1976D2); // Azul fuerte (Tren Superior)
        case 'Icons.directions_walk':
          return const Color(0xFFC6DA23); // Verde claro (Tren Inferior)
        case 'Icons.self_improvement':
          return const Color(0xFF26C6DA); // Turquesa (Movilidad Articular)
        case 'Icons.extension':
          return const Color(
            0xFFFF8A65,
          ); // Naranja suave (Estiramientos Generales)
        default:
          break;
      }

      return const Color(0xFF4CAF50); // Cambiado de withOpacity(0.1)
    }

    Color getTextColor(String id) {
      return const Color.fromARGB(255, 255, 255, 255);
    }

    final cardColor = getCardColor(activity['icono']);
    final textColor = getTextColor(activity['id']);
    final sensorEnabled =
        activity['sensorEnabled'] is bool
            ? activity['sensorEnabled']
            : activity['sensorEnabled'].toString().toLowerCase() == 'true';

    return Container(
      decoration: BoxDecoration(
        color:
            isSelected
                ? cardColor.withAlpha(51)
                : Colors.white, // Cambiado de withOpacity(0.2)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? textColor
                  : Colors.grey.withAlpha(51), // Cambiado de withOpacity(0.2)
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withAlpha(26), // Cambiado de withOpacity(0.1)
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _editActivity(activity),
            child: Stack(
              children: [
                // Fondo decorativo
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: cardColor.withAlpha(
                        51,
                      ), // Cambiado de withOpacity(0.2)
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(activity['icono']),
                              color: textColor,
                              size: 38,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['nombre'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                      255,
                                      143,
                                      143,
                                      143,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    sensorEnabled
                                        ? 'Requiere sensor'
                                        : 'Sin sensor',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 18,
                      ), // Espacio entre el row superior y la descripción
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            activity['descripcion'] ?? '',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 143, 143, 143),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      // Mostrar pasos si existen
                      if (activity['pasos'] != null &&
                          activity['pasos'] is List &&
                          (activity['pasos'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pasos:',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    143,
                                    143,
                                    143,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...List<Widget>.from(
                                (activity['pasos'] as List).map(
                                  (step) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      '- $step',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          143,
                                          143,
                                          143,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ' ${activity['duracion']}s',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editActivity(activity),
                                color: cardColor,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteActivity(activity),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedActivities.add(activity['id']);
                          } else {
                            _selectedActivities.remove(activity['id']);
                          }
                          _selectAll =
                              _selectedActivities.length == _activities.length;
                        });
                      },
                      activeColor: textColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconString) {
    // El string viene como "Icons.psychology", extraemos el nombre del icono
    final iconName = iconString.split('.').last;

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

  Future<void> _editActivity(Map<String, dynamic> activity) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditActivityDialog(activity: activity),
    );

    if (result == true) {
      _loadActivities(); // Recargar la lista después de editar
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Está seguro de eliminar la actividad "${activity['nombre']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await ActivityService.deleteActivity(activity['id']);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actividad eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadActivities();
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
  }
}
