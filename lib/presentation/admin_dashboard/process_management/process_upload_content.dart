import 'package:flutter/material.dart';
import '../../../core/services/process_upload_service.dart';
import '../../../core/services/serv_actividades/process_group_service.dart';
import '../../../core/services/serv_actividades/plan_service.dart';
import '../../../data/models/process_group.dart';

class ProcessUploadContent extends StatefulWidget {
  const ProcessUploadContent({super.key});

  @override
  State<ProcessUploadContent> createState() => _ProcessUploadContentState();
}

class _ProcessUploadContentState extends State<ProcessUploadContent> {
  final _formKey = GlobalKey<FormState>();
  final _processNameController = TextEditingController();
  final ProcessUploadService _uploadService = ProcessUploadService();
  final ProcessGroupService _groupService = ProcessGroupService();

  List<dynamic> _groups = [];
  List _pausePlans = [];
  String? _selectedGroupId;
  final List<String> _selectedPausePlanIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load groups
      final groups = await _groupService.getGroups();

      // Load active pause plans
      final pausePlans = await PlanService.getPlans();
      debugPrint('📦 Pause plans loaded: ${pausePlans.length}');

      if (mounted) {
        setState(() {
          _groups = groups;
          _pausePlans = pausePlans;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error loading data: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.cloud_upload, size: 32, color: Color(0xFF0067AC)),
        const SizedBox(width: 16),
        const Text(
          'Asignación de Procesos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _loadInitialData,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0067AC),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupSelection(),
              const SizedBox(height: 24),
              _buildProcessNameField(),
              const SizedBox(height: 24),
              Expanded(child: _buildPausePlansList()),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelection() {
    return DropdownButtonFormField<String>(
      value: _selectedGroupId,
      items:
          _groups
              .map(
                (group) => DropdownMenuItem<String>(
                  value: group['id'] as String?,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(group['color']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(group['name']),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _selectedGroupId = value),
      decoration: const InputDecoration(
        labelText: 'Seleccionar Grupo',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildProcessNameField() {
    return TextFormField(
      controller: _processNameController,
      decoration: const InputDecoration(
        labelText: 'Nombre del Proceso',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Por favor ingrese un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildPausePlansList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.green[700]),
                const SizedBox(width: 12),
                const Text(
                  'Planes de Pausa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pausePlans.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final plan = _pausePlans[index];
                final planId = plan['id']?.toString() ?? '';
                final isSelected =
                    _selectedPausePlanIds.isNotEmpty &&
                    _selectedPausePlanIds.first == planId;
                return Card(
                  elevation: 0,
                  color: Color(
                    int.tryParse(plan['color'].toString()) ?? 0xFF4CAF50,
                  ).withAlpha(80),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: RadioListTile<String>(
                    value: planId,
                    groupValue:
                        _selectedPausePlanIds.isNotEmpty
                            ? _selectedPausePlanIds.first
                            : null,
                    onChanged: (selectedId) {
                      setState(() {
                        _selectedPausePlanIds
                          ..clear()
                          ..add(selectedId ?? '');
                      });
                    },
                    title: Text(
                      plan['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(plan['descripcion'] ?? 'Sin descripción'),
                    activeColor: Colors.green[700],
                    selected: isSelected,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _cancelUpload,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _uploadProcess,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Subir Proceso'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _cancelUpload() {
    _processNameController.clear();
    setState(() {
      _selectedGroupId = null;
      _selectedPausePlanIds.clear();
    });
  }

  Future<void> _uploadProcess() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGroupId == null) {
      _showSnackBar('Por favor seleccione un grupo', isError: true);
      return;
    }

    if (_selectedPausePlanIds.isEmpty) {
      _showSnackBar('Seleccione al menos un plan de pausa', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final response = await _uploadService.uploadProcess(
        groupId: _selectedGroupId!,
        processName: _processNameController.text,
        pausePlanIds: _selectedPausePlanIds,
      );

      if (!mounted) return;

      _showSnackBar('Proceso subido exitosamente');
      _cancelUpload();

      final updatedPausePlans = await PlanService.getPlans();
      setState(() {
        _pausePlans = updatedPausePlans;
      });

      debugPrint('📦 Respuesta del servidor: $response');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al subir el proceso: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
