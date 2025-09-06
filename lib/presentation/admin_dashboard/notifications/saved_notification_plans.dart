import 'package:flutter/material.dart';
import '../../../core/services/serv_actividades/notification_service.dart';
import '../../../data/models/notification_plan.dart';
import 'package:intl/intl.dart';

class SavedNotificationPlans extends StatefulWidget {
  const SavedNotificationPlans({super.key});

  @override
  State<SavedNotificationPlans> createState() => _SavedNotificationPlansState();
}

class _SavedNotificationPlansState extends State<SavedNotificationPlans> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationPlan> _plans = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      debugPrint('🔄 Cargando planes de notificaciones...');
      final plans = await _notificationService.getNotificationPlans();

      if (!mounted) return;
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
      debugPrint('✅ Planes cargados: ${plans.length}');
    } catch (e) {
      debugPrint('❌ Error cargando planes: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePlan(NotificationPlan plan) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _notificationService.deleteNotification(plan.id);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      _showSnackBar('✅ Plan eliminado exitosamente');
      _loadPlans();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading
      _showSnackBar('❌ Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _togglePlanStatus(NotificationPlan plan) async {
    try {
      debugPrint('🔄 Intentando actualizar estado del plan: ${plan.id}');

      if (plan.id.trim().isEmpty) {
        throw Exception('ID de plan no válido o vacío');
      }

      setState(() {
        plan.isLoading = true;
      });

      await _notificationService.updatePlanStatus(
        plan.id.trim(),
        !plan.isActive,
      );

      setState(() {
        plan.isActive = !plan.isActive;
      });

      _showSnackBar(
        '✅ Estado actualizado: ${plan.isActive ? 'Activo' : 'Inactivo'}',
        backgroundColor: plan.isActive ? Colors.green : Colors.orange,
      );

      await _loadPlans();
    } catch (e) {
      debugPrint('❌ Error actualizando estado: $e');
      _showSnackBar('❌ Error: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          plan.isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    Color? backgroundColor,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            backgroundColor ?? (isError ? Colors.red : Colors.green),
      ),
    );
  }

  List<NotificationPlan> get _filteredPlans =>
      _plans
          .where(
            (plan) =>
                plan.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();

  Widget _buildPlanCard(NotificationPlan plan) {
    final totalPlans = plan.assignedPlans.values.fold<int>(
      0,
      (sum, plans) => sum + plans.length,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: plan.isActive ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0067AC).withAlpha(13),
              const Color(0xFF0067AC).withAlpha(5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
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
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                      Text(
                        'Creado el ${DateFormat('dd/MM/yyyy').format(plan.createdAt)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF0067AC)),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(plan);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Período',
              '${DateFormat('dd/MM/yyyy').format(plan.startDate)} - ${DateFormat('dd/MM/yyyy').format(plan.endDate)}',
              Icons.date_range,
            ),
            _buildInfoRow('Hora de notificación', plan.time, Icons.access_time),
            _buildInfoRow(
              'Total de planes',
              '$totalPlans planes programados',
              Icons.playlist_play,
            ),
            const SizedBox(height: 16),
            Text(
              'Estado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        plan.isActive
                            ? Colors.green.withAlpha(26)
                            : Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        plan.isActive ? Icons.check_circle : Icons.cancel,
                        color: plan.isActive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plan.isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: plan.isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                plan.isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Switch(
                      value: plan.isActive,
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.red.withAlpha(100),
                      onChanged: (value) => _togglePlanStatus(plan),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0067AC), size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF0067AC),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(NotificationPlan plan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Está seguro de eliminar el plan "${plan.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlans,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 32,
                  color: Color(0xFF0067AC),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Planes de Notificaciones Guardados',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 300,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar planes...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: const Color(0xFF0067AC),
                  onPressed: _loadPlans,
                  tooltip: 'Actualizar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_plans.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay planes guardados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _filteredPlans.length,
                itemBuilder:
                    (context, index) => _buildPlanCard(_filteredPlans[index]),
              ),
            ),
        ],
      ),
    );
  }
}
