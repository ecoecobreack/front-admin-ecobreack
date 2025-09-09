import 'package:flutter/material.dart';
import '../../../core/services/serv_actividades/drive_service.dart';
import '../../../core/services/serv_actividades/activity_service.dart';
import 'components/video_selector_dialog.dart';
import '../../../widgets/web_video_player.dart'; // Nuevo import

class CreateActivityContent extends StatefulWidget {
  const CreateActivityContent({super.key});

  @override
  State<CreateActivityContent> createState() => _CreateActivityContentState();
}

class _CreateActivityContentState extends State<CreateActivityContent> {
  // Declaración de controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxTimeController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();

  // Variables de estado
  String? _selectedCategory;
  bool _showSensorSwitch = false;
  bool _sensorEnabled = false;
  bool _isVideoLoading = false;
  Map<String, dynamic>? _selectedVideo;
  final List<String> _activityLog = [];
  final TextEditingController _stepController = TextEditingController();
  final List<String> _steps = [];

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
        _initializeVideo(result);
      });
    }
  }

  Future<void> _initializeVideo(Map<String, dynamic> video) async {
    setState(() => _isVideoLoading = true);
    try {
      final streamUrl = DriveService.getStreamUrl(video);
      if (streamUrl == null) throw Exception('URL de stream no válida');
      setState(() => _isVideoLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVideoLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el video. Intente con otro video.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _validateTimeInputs() async {
    final maxTime = int.tryParse(_maxTimeController.text);

    if (maxTime! > 300) {
      // 5 minutos máximo
      throw Exception(
        'El tiempo máximo no puede exceder los 5 minutos (300 segundos)',
      );
    }
    return Future.value();
  }

  Future<void> _saveActivity() async {
    try {
      await _validateTimeInputs();

      // Verificar campos antes de la operación asíncrona
      if (_videoLinkController.text.isEmpty ||
          _nameController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _maxTimeController.text.isEmpty ||
          _selectedCategory == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor complete todos los campos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar el video de Drive
      if (_videoLinkController.text.contains('drive.google.com')) {
        final isValid = await DriveService.validateDriveFile(
          _videoLinkController.text,
        );
        if (!mounted) return;

        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El video debe estar en la carpeta de EcoBreack'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final result = await ActivityService.createActivity(
        name: _nameController.text,
        description: _descriptionController.text,
        videoUrl: _videoLinkController.text,
        maxTime: int.parse(_maxTimeController.text),
        steps: _steps,
        icon: _getIconString(_selectedCategory),
        sensorEnabled: _sensorEnabled,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        // Add log entry
        setState(() {
          _activityLog.add(
            '[${DateTime.now().toString()}] Creada actividad: ${_nameController.text} - Categoría: $_selectedCategory',
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _maxTimeController.clear();
    _videoLinkController.clear();
    setState(() {
      _selectedCategory = null;
      _sensorEnabled = false;
    });
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_selectedVideo != null) {
      final videoId = _selectedVideo!['id'];
      return KeyedSubtree(
        // Añadir KeyedSubtree
        key: ValueKey(videoId), // Usar el videoId como key
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[800],
          ),
          clipBehavior: Clip.antiAlias,
          child: WebVideoPlayer(embedUrl: DriveService.getEmbedUrl(videoId)),
        ),
      );
    }

    return const Center(
      child: Text(
        'Seleccione un video para reproducir',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video de la Actividad',
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
                controller: _videoLinkController,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Seleccione un video...',
                  prefixIcon: const Icon(Icons.movie),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showVideoSelector,
              icon: const Icon(Icons.video_library, color: Colors.white),
              label: Text(
                _selectedVideo == null ? 'Seleccionar Video' : 'Cambiar Video',
                style: const TextStyle(color: Colors.white),
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
        const SizedBox(height: 16),
        if (_selectedVideo != null || _isVideoLoading)
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildVideoPlayer(),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  set sensorEnabled(bool value) {
    setState(() {
      _sensorEnabled = value;
    });

    if (_sensorEnabled) {
      debugPrint('✅ Sensor de movimiento activado');
    } else {
      debugPrint('❌ Sensor de movimiento desactivado');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helperText,
    int maxLines = 1,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: const TextStyle(color: Colors.grey),
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
        if (_steps.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0067AC).withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nueva Actividad / Ejercicio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaRounded',
                color: Color(0xFF0067AC),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Nombre del Ejercicio',
              hint: 'Ingrese el nombre del ejercicio',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
              hint: 'Describa el ejercicio',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildStepsSection(), // <-- Agrega la sección de pasos aquí
            const SizedBox(height: 16),
            _buildTimeSelector(),
            const SizedBox(height: 16),
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
                    _buildDropdownItem(Icons.directions_walk, 'Movilidad'),
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
                          sensorEnabled = value;
                        },
                        activeColor: const Color(0xFF0067AC),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVideoSection(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Lógica para cancelar
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'HelveticaRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0067AC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Guardar Actividad',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'HelveticaRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_activityLog.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Registro de Actividades Creadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _activityLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        _activityLog[_activityLog.length - 1 - index],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
