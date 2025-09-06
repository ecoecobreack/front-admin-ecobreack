import 'package:flutter/material.dart';
import '../../../../../core/services/serv_actividades/activity_service.dart';
import '../../../../../core/services/serv_actividades/drive_service.dart';
import '../video_selector_dialog.dart';

class EditActivityDialog extends StatefulWidget {
  final Map<String, dynamic> activity;

  const EditActivityDialog({super.key, required this.activity});

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _minTimeController;
  late TextEditingController _maxTimeController;
  late TextEditingController _videoLinkController;
  String? _selectedCategory;
  bool _sensorEnabled = false;
  bool _showSensorSwitch = false;
  Map<String, dynamic>? _selectedVideo;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.activity['name']);
    _descriptionController = TextEditingController(
      text: widget.activity['description'],
    );
    _minTimeController = TextEditingController(
      text: widget.activity['minTime'].toString(),
    );
    _maxTimeController = TextEditingController(
      text: widget.activity['maxTime'].toString(),
    );
    _videoLinkController = TextEditingController(
      text: DriveService.getVideoName({'id': widget.activity['videoUrl']}),
    );
    _selectedCategory = widget.activity['category'];
    _sensorEnabled = widget.activity['sensorEnabled'];
    _selectedVideo = {'id': widget.activity['videoUrl']};
    _showSensorSwitch =
        _selectedCategory == 'Tren Superior' ||
        _selectedCategory == 'Movilidad Articular';
  }

  Future<void> _showVideoSelector() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => VideoSelectorDialog(
            onVideoSelected: (video) {
              Navigator.pop(context, video);
            },
          ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedVideo = result;
        _videoLinkController.text = DriveService.getVideoName(result);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minTimeController.dispose();
    _maxTimeController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Sanitize inputs before sending
      final sanitizedName = _nameController.text.trim();
      final sanitizedDescription = _descriptionController.text.trim();

      // Validate numeric inputs
      final minTime = int.tryParse(_minTimeController.text);
      final maxTime = int.tryParse(_maxTimeController.text);

      if (minTime == null || maxTime == null) {
        throw Exception('Los tiempos deben ser números válidos');
      }

      if (maxTime <= minTime) {
        throw Exception('El tiempo máximo debe ser mayor al tiempo mínimo');
      }

      final result = await ActivityService.updateActivity(
        id: widget.activity['id'],
        name: sanitizedName,
        description: sanitizedDescription,
        minTime: minTime,
        maxTime: maxTime,
        category: _selectedCategory!,
        videoUrl: _selectedVideo!['id'],
        sensorEnabled: _sensorEnabled,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Actividad actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF0067AC)),
                    const SizedBox(width: 12),
                    const Text(
                      'Editar Actividad',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Nombre
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre del Ejercicio',
                  hint: 'Ingrese el nombre del ejercicio',
                ),
                const SizedBox(height: 16),
                // Descripción
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describa el ejercicio',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Selector de tiempo
                _buildTimeSelector(),
                const SizedBox(height: 16),
                // Categoría
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Seleccione una categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0067AC),
                            width: 2,
                          ),
                        ),
                      ),
                      items: [
                        _buildDropdownItem('Visual', Icons.visibility),
                        _buildDropdownItem('Auditiva', Icons.hearing),
                        _buildDropdownItem('Cognitiva', Icons.psychology),
                        _buildDropdownItem(
                          'Tren Superior',
                          Icons.accessibility_new,
                        ),
                        _buildDropdownItem(
                          'Tren Inferior',
                          Icons.directions_walk,
                        ),
                        _buildDropdownItem(
                          'Movilidad Articular',
                          Icons.self_improvement,
                        ),
                        _buildDropdownItem(
                          'Estiramientos Generales',
                          Icons.accessibility,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _showSensorSwitch =
                              value == 'Tren Superior' ||
                              value == 'Movilidad Articular';
                          if (!_showSensorSwitch) {
                            _sensorEnabled = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sensor de movimiento
                if (_showSensorSwitch)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0067AC).withAlpha(13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0067AC).withAlpha(26),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors, color: Color(0xFF0067AC)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sensor de Movimiento',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0067AC),
                                ),
                              ),
                              Text(
                                'Activar detección de movimiento para esta actividad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _sensorEnabled,
                          onChanged: (value) {
                            setState(() {
                              _sensorEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF0067AC),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                // Video selector
                _buildVideoSelector(),
                const SizedBox(height: 24),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0067AC),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0067AC), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String text, IconData icon) {
    final Map<String, IconData> categoryIcons = {
      'Visual': Icons.visibility,
      'Auditiva': Icons.hearing,
      'Cognitiva': Icons.psychology,
      'Tren Superior': Icons.accessibility_new,
      'Tren Inferior': Icons.directions_walk,
      'Movilidad Articular': Icons.self_improvement,
      'Estiramientos Generales': Icons.accessibility,
    };

    return DropdownMenuItem<String>(
      value: text,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcons[text] ?? Icons.circle,
              color: const Color(0xFF0067AC),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'HelveticaRounded',
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _minTimeController,
            label: 'Tiempo Mínimo (segundos)',
            hint: 'Ingrese el tiempo mínimo',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _maxTimeController,
            label: 'Tiempo Máximo (segundos)',
            hint: 'Ingrese el tiempo máximo',
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _videoLinkController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Video actual',
                      prefixIcon: const Icon(Icons.movie),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (widget.activity['videoUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF0067AC),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Video actual: ${widget.activity['videoUrl']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showVideoSelector,
              icon: const Icon(Icons.video_library, color: Colors.white),
              label: const Text(
                'Cambiar Video',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0067AC),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
