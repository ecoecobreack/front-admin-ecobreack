import 'package:flutter/material.dart';
import '../../../../../core/services/serv_actividades/plan_service.dart';
import 'edit_plan_dialog.dart';

class EditPlansContent extends StatefulWidget {
  const EditPlansContent({super.key});

  @override
  State<EditPlansContent> createState() => _EditPlansContentState();
}

class _EditPlansContentState extends State<EditPlansContent> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = false;
  final PlanService _planService = PlanService();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Plans loaded');
      final plans = await _planService.getPlans();
      debugPrint('Loaded plans: $plans'); // Aquí deberías ver los datos
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading plans: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePlan(String id) async {
    try {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirmar Eliminación'),
              content: const Text(
                '¿Está seguro de que desea eliminar este plan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
      );

      if (!mounted) return;

      if (confirm == true) {
        await PlanService.deletePlan(id);

        if (!mounted) return;

        // Usar ScaffoldMessenger con el contexto actual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        await _loadPlans();
      }
    } catch (e) {
      if (!mounted) return;

      // Usar ScaffoldMessenger con el contexto actual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error eliminando plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editPlan(Map<String, dynamic> plan) async {
    if (!mounted) return;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => EditPlanDialog(plan: plan),
      );

      if (!mounted) return;

      if (result == true) {
        await _loadPlans();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error editando plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          const SizedBox(height: 24),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _plans.isEmpty
                    ? const Center(
                      child: Text(
                        'No hay planes creados',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.playlist_play,
                              color: Color(0xFF0067AC),
                            ),
                            title: Text(plan['nombre']),
                            subtitle: Text(plan['descripcion'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editPlan(plan),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deletePlan(plan['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.playlist_add_check,
          size: 32,
          color: Color(0xFF0067AC),
        ),
        const SizedBox(width: 16),
        const Text(
          'Planes de Pausas Creados',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _loadPlans,
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
}
