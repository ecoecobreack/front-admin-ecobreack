import 'package:flutter/material.dart';
import '../../../core/services/serv_actividades/plan_service.dart';
import 'components/crearPlan/plan_details_dialog.dart';
import 'components/crearPlan/edit_plan_dialog.dart';

class EditPlansContent extends StatefulWidget {
  const EditPlansContent({super.key});

  @override
  State<EditPlansContent> createState() => _EditPlansContentState();
}

class _EditPlansContentState extends State<EditPlansContent> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';
  bool _selectAll = false;
  Set<String> _selectedPlans = {};

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final plans = await PlanService.getPlans();
      
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(_error, style: TextStyle(color: Colors.red.shade400)),
          ],
        ),
      );
    }

    final filteredPlans = _plans.where((plan) {
      return plan['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: filteredPlans.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: filteredPlans.length,
                    itemBuilder: (context, index) {
                      return _buildPlanCard(filteredPlans[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            'Planes Creados',
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
              if (_plans.isNotEmpty) ...[
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
                            _selectedPlans = _selectAll 
                                ? _plans.map((e) => e['id'] as String).toSet()
                                : {};
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
              if (_selectedPlans.isNotEmpty)
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
                    onPressed: _deleteSelectedPlans,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text('Eliminar (${_selectedPlans.length})'),
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
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar plan...',
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
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0067AC).withAlpha(50),
            const Color(0xFF0067AC).withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0067AC).withAlpha(20),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPlanDetails(plan),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0067AC).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: const Color(0xFF0067AC).withAlpha(200),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['name'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0067AC),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Creado el ${_formatDate(plan['createdAt'])}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Color(0xFF0067AC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Color(0xFF0067AC)),
                              const SizedBox(width: 8),
                              const Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Eliminar', 
                                style: TextStyle(color: Colors.red)
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _editPlan(plan);
                        } else if (value == 'delete') {
                          _confirmDeletePlan(plan);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  plan['description'] ?? 'Sin descripción',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      icon: Icons.fitness_center,
                      label: '${(plan['activities'] as List?)?.length ?? 0} ejercicios',
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

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0067AC).withAlpha(10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0067AC)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0067AC),
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
            Icons.playlist_add,
            size: 64,
            color: const Color(0xFF0067AC).withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay planes creados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un nuevo plan para empezar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDetails(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => PlanDetailsDialog(plan: plan),
    );
  }

  void _confirmDeletePlan(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de eliminar el plan "${plan['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deletePlan(plan);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan(Map<String, dynamic> plan) async {
    try {
      await PlanService.deletePlan(plan['id']);
      
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Plan eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPlans();
    } catch (e) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editPlan(Map<String, dynamic> plan) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditPlanDialog(plan: plan),
    );
    
    if (result == true) {
      _loadPlans(); // Recargar la lista después de editar
    }
  }

  Future<void> _deleteSelectedPlans() async {
    try {
      for (String planId in _selectedPlans) {
        await PlanService.deletePlan(planId);
      }
      
      if (!mounted) return;

      setState(() {
        _selectedPlans.clear();
        _selectAll = false;
      });
      
      _loadPlans();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Planes eliminados exitosamente'),
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

  String _formatDate(String? date) {
    if (date == null) return 'Desconocido';
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return 'Desconocido';
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }
}
