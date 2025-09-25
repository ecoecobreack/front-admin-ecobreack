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

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _maxTimeController = TextEditingController();
  TextEditingController _videoLinkController = TextEditingController();

  // Variables de estado
  String? _selectedCategory;
  bool _sensorEnabled = false;
  bool _showSensorSwitch = false;
  Map<String, dynamic>? _selectedVideo;
  final TextEditingController _stepController = TextEditingController();
  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _steps = List<String>.from(widget.activity['pasos'] ?? []);
  }

  IconData _iconStringToLabel(String iconString) {
    switch (iconString) {
      case 'Icons.visibility':
        return Icons.visibility;
      case 'Icons.hearing':
        return Icons.hearing;
      case 'Icons.psychology':
        return Icons.psychology;
      case 'Icons.accessibility_new':
        return Icons.accessibility_new;
      case 'Icons.directions_walk':
        return Icons.directions_walk;
      case 'Icons.self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.help_outline;
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.activity['nombre']);
    _descriptionController = TextEditingController(
      text: widget.activity['descripcion'],
    );
    _maxTimeController = TextEditingController(
      text: widget.activity['duracion'].toString(),
    );
    _videoLinkController = TextEditingController(
      text:  widget.activity['videoUrl'],
    );
    _selectedCategory = widget.activity['category'];
    _sensorEnabled =
        widget.activity['sensorEnabled'] is bool
            ? widget.activity['sensorEnabled']
            : widget.activity['sensorEnabled'].toString().toLowerCase() ==
                'true';
    _selectedVideo = {'id': widget.activity['videoUrl']};
    _showSensorSwitch =
        _selectedCategory == 'Tren Superior' ||
        _selectedCategory == 'Movilidad Articular';
    _iconStringToLabel(widget.activity['icono']);
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
    _maxTimeController.dispose();
    _videoLinkController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  String _getIconString(String? categoria) {
    switch (categoria) {
      case 'Visibilidad':
        return 'Icons.visibility';
      case 'Audición':
        return 'Icons.hearing';
      case 'Psicología':
        return 'Icons.psychology';
      case 'Accesibilidad':
        return 'Icons.accessibility_new';
      case 'Movilidad':
        return 'Icons.directions_walk';
      case 'Mejora Personal':
        return 'Icons.self_improvement';
      default:
        return 'Icons.help_outline';
    }
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pasos del Ejercicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _stepController,
                decoration: InputDecoration(
                  hintText: 'Escribe un paso y presiona "+"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final step = _stepController.text.trim();
                if (step.isNotEmpty) {
                  setState(() {
                    _steps.add(step);
                    _stepController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0067AC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_steps.isNotEmpty) ...[
          const Text(
            'Pasos actuales:',
            style: TextStyle(
              color: Color(0xFF0067AC),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_steps[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _steps.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Sanitize inputs before sending
      final sanitizedName = _nameController.text.trim();
      final sanitizedDescription = _descriptionController.text.trim();

      // Validate numeric inputs

      final maxTime = int.tryParse(_maxTimeController.text);

      if (maxTime == null || maxTime <= 0) {
        throw Exception('Tiempo máximo inválido');
      }

      final result = await ActivityService.updateActivity(
        id: widget.activity['id'].toString(),
        name:
            _nameController.text.isNotEmpty
                ? _nameController.text
                : widget.activity['nombre'],
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : widget.activity['descripcion'],
        videoUrl: _videoLinkController.text.isNotEmpty ? _videoLinkController.text : widget.activity['video'] ?? '',
        maxTime:
            int.parse(_maxTimeController.text) == 0
                ? widget.activity['duracion']
                : int.parse(_maxTimeController.text),
        steps:
            _steps.isNotEmpty
                ? _steps
                : List<String>.from(widget.activity['pasos'] ?? []),
        icon:
            _getIconString(_selectedCategory) == 'Icons.help_outline'
                ? widget.activity['icono']
                : _getIconString(_selectedCategory),
        sensorEnabled:
            _sensorEnabled == widget.activity['sensorEnabled']
                ? widget.activity['sensorEnabled']
                : _sensorEnabled,
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
                _buildStepsSection(),
                const SizedBox(height: 16),
                // Selector de tiempo
                _buildTimeSelector(),
                const SizedBox(height: 16),
                // Categoría
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Icono para el Ejercicio',
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
                            hintText: 'Seleccione un icono para la categoría',
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            _buildDropdownItem(Icons.visibility, 'Visibilidad'),
                            _buildDropdownItem(Icons.hearing, 'Audición'),
                            _buildDropdownItem(Icons.psychology, 'Psicología'),
                            _buildDropdownItem(
                              Icons.accessibility_new,
                              'Accesibilidad',
                            ),
                            _buildDropdownItem(
                              Icons.directions_walk,
                              'Movilidad',
                            ),
                            _buildDropdownItem(
                              Icons.self_improvement,
                              'Mejora Personal',
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
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF0067AC),
                          ),
                          dropdownColor: Colors.white,
                          elevation: 3,
                        ),
                        const SizedBox(height: 16),
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
                              const Icon(
                                Icons.sensors,
                                color: Color(0xFF0067AC),
                              ),
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
                      ],
                    ),
                    const Text(
                      'Categoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    ),
                    const SizedBox(height: 8),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(IconData icon, String label) {
    return DropdownMenuItem<String>(
      value: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF0067AC), size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duración del Ejercicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0067AC).withAlpha(13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0067AC).withAlpha(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tiempo Máximo',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0067AC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _maxTimeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  suffixIcon: const Tooltip(
                                    message: 'Tiempo en segundos',
                                    child: Icon(Icons.timer),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTimePresetButton('30s', '30'),
                            const SizedBox(width: 4),
                            _buildTimePresetButton('45s', '45'),
                            const SizedBox(width: 4),
                            _buildTimePresetButton('60s', '60'),
                            const SizedBox(width: 4),
                            _buildTimePresetButton('90s', '90'),
                            const SizedBox(width: 4),
                            _buildTimePresetButton('120s', '120'),
                            const SizedBox(width: 4),
                            _buildTimePresetButton('180s', '180'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0067AC).withAlpha(5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0067AC).withAlpha(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF0067AC),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Guía de Tiempos Recomendados:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0067AC),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Ejercicios simples: 30-60 segundos\n'
                      '• Ejercicios intermedios: 60-120 segundos\n'
                      '• Ejercicios completos: 120-180 segundos\n'
                      '• El tiempo mínimo debe ser al menos 10 segundos\n'
                      '• El tiempo máximo no debe exceder 5 minutos (300 segundos)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePresetButton(String label, String value) {
    return InkWell(
      onTap: () {
        final controller = _maxTimeController;
        controller.text = value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0067AC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
