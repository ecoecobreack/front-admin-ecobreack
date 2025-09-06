import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/notification_plan.dart';
import '../../../core/services/serv_actividades/notification_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/serv_users/auth_service.dart';

class NotificationContent extends StatefulWidget {
  const NotificationContent({super.key});

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> _assignedPlans = {};
  List<Map<String, dynamic>> _availablePlans =
      []; // Cambiar a lista vacía inicial

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSyncedPlans();
  }

  Future<void> _loadSyncedPlans() async {
    try {
      debugPrint('🔄 Cargando planes de pausa...');
      final token = await AuthService.getAdminToken();
      final response = await ApiService().get(
        '/admin/plans',
        query: {'token': token},
      );

      if (response['status'] == true && response['data'] != null) {
        final plans = List<Map<String, dynamic>>.from(response['data']);
        debugPrint('✅ Planes cargados: ${plans.length}');

        setState(() {
          // Convertir cada plan de pausa en un plan disponible
          _availablePlans =
              plans
                  .map(
                    (plan) => {
                      'id': plan['id'],
                      'name': plan['name'],
                      'time': plan['time'] ?? '08:00',
                      'color': const Color(0xFF0067AC),
                      'isAssigned': false,
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando planes: $e');
      _showSnackBar('Error cargando planes: $e', backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _timeController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear Plan de Notificaciones',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0067AC),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNameField(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildDateField(true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDateField(false)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTimeField()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSyncedPlansSection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _buildAvailablePlans()),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: _buildCalendar()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _showCancelConfirmation,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
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
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Guardar Plan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.notifications, size: 32, color: Color(0xFF0067AC)),
        SizedBox(width: 16),
        Text(
          'Gestión de Notificaciones',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0067AC),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre del Plan',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(bool isStartDate) {
    final theme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0067AC),
        onSurface: Color(0xFF0067AC),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF0067AC)),
      ),
    );

    return TextFormField(
      controller: isStartDate ? _startDateController : _endDateController,
      decoration: InputDecoration(
        labelText: isStartDate ? 'Fecha de Inicio' : 'Fecha de Fin',
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF0067AC)),
      ),
      readOnly: true,
      onTap: () async {
        try {
          debugPrint('📅 Abriendo selector de fecha...');

          final now = DateTime.now();
          final initialDate =
              isStartDate
                  ? now
                  : _startDateController.text.isNotEmpty
                  ? DateFormat('dd/MM/yyyy').parse(_startDateController.text)
                  : now;

          final firstDate = isStartDate ? now : initialDate;
          final lastDate = DateTime(now.year + 2, now.month, now.day);

          debugPrint('📅 Configuración de fechas:');
          debugPrint('   - Fecha inicial: $initialDate');
          debugPrint('   - Fecha mínima: $firstDate');
          debugPrint('   - Fecha máxima: $lastDate');

          if (!mounted) return;

          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            locale: const Locale('es', 'ES'),
            builder: (context, child) => Theme(data: theme, child: child!),
          );

          if (picked != null && mounted) {
            debugPrint('📅 Fecha seleccionada: $picked');
            setState(() {
              final formatter = DateFormat('dd/MM/yyyy', 'es');
              if (isStartDate) {
                _startDateController.text = formatter.format(picked);
                // Limpiar fecha fin si es posterior a la nueva fecha inicio
                if (_endDateController.text.isNotEmpty) {
                  final endDate = formatter.parse(_endDateController.text);
                  if (endDate.isBefore(picked)) {
                    _endDateController.clear();
                  }
                }
              } else {
                _endDateController.text = formatter.format(picked);
              }
            });
          }
        } catch (e) {
          debugPrint('❌ Error al abrir el selector de fecha: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al abrir el calendario: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildTimeField() {
    final theme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0067AC),
        onSurface: Color(0xFF0067AC),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF0067AC)),
      ),
    );

    return TextFormField(
      controller: _timeController,
      decoration: InputDecoration(
        labelText: 'Hora',
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0067AC), width: 2),
        ),
        suffixIcon: const Icon(Icons.access_time, color: Color(0xFF0067AC)),
      ),
      readOnly: true,
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(data: theme, child: child!),
        );
        if (picked != null) {
          setState(() {
            // Formato 24 horas
            final hour = picked.hour.toString().padLeft(2, '0');
            final minute = picked.minute.toString().padLeft(2, '0');
            _timeController.text = '$hour:$minute';
          });
        }
      },
    );
  }

  Widget _buildAvailablePlans() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Planes Disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _availablePlans.length,
              itemBuilder: (context, index) {
                final plan = _availablePlans[index];
                if (plan['isAssigned']) return const SizedBox.shrink();
                return _buildDraggablePlan(plan, true);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Seleccionar color para ${plan['name']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption(const Color(0xFF0067AC), plan),
                      _buildColorOption(const Color(0xFFC6DA23), plan),
                      _buildColorOption(const Color(0xFFFF6B6B), plan),
                      _buildColorOption(const Color(0xFF9C27B0), plan),
                      _buildColorOption(const Color(0xFF4CAF50), plan),
                      _buildColorOption(const Color(0xFFFFA726), plan),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildColorOption(Color color, Map<String, dynamic> plan) {
    return InkWell(
      onTap: () {
        setState(() {
          plan['color'] = color;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildDraggablePlan(Map<String, dynamic> plan, bool isTemplate) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        if (!isTemplate) {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          showMenu(
            context: context,
            position: RelativeRect.fromRect(
              details.globalPosition & const Size(48, 48),
              Offset.zero & overlay.size,
            ),
            items: [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Cambiar color'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap:
                    () => Future.delayed(
                      const Duration(milliseconds: 200),
                      () => _showColorPicker(plan),
                    ),
              ),
              if (!isTemplate)
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Eliminar plan'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    setState(() {
                      final sourceDay = _selectedDay;
                      if (sourceDay != null) {
                        _assignedPlans[sourceDay]?.removeWhere(
                          (p) =>
                              p['id'] == plan['id'] &&
                              p['time'] == plan['time'],
                        );
                        if (_assignedPlans[sourceDay]?.isEmpty ?? false) {
                          _assignedPlans.remove(sourceDay);
                        }
                        final originalPlan = _availablePlans.firstWhere(
                          (p) => p['id'] == plan['id'],
                        );
                        originalPlan['isAssigned'] = false;
                      }
                    });
                  },
                ),
            ],
          );
        }
      },
      child: Draggable<Map<String, dynamic>>(
        data: {...plan, 'isTemplate': isTemplate},
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: plan['color'] ?? const Color(0xFF0067AC),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alarm,
                  color: plan['color'] ?? const Color(0xFF0067AC),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  plan['name'],
                  style: TextStyle(
                    color: plan['color'] ?? const Color(0xFF0067AC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.5, child: _buildPlanTile(plan)),
        onDragStarted: () {
          if (isTemplate) {
            setState(() {
              plan['isAssigned'] = true;
            });
          }
        },
        onDraggableCanceled: (_, __) {
          if (isTemplate) {
            setState(() {
              plan['isAssigned'] = false;
            });
          }
        },
        child: _buildPlanTile(plan),
      ),
    );
  }

  Widget _buildPlanTile(Map<String, dynamic> plan) {
    return ListTile(
      title: Text(plan['name']),
      subtitle: Text('Hora: ${plan['time']}'),
      leading: Icon(
        Icons.drag_indicator,
        color: plan['color'] ?? const Color(0xFF0067AC),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showPlanOptions(plan),
      ),
      enabled: !plan['isAssigned'],
    );
  }

  void _showPlanOptions(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Cambiar color'),
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker(plan);
                  },
                ),
                if (_selectedDay != null &&
                    _assignedPlans.containsKey(_selectedDay) &&
                    _assignedPlans[_selectedDay]!.any(
                      (p) => p['id'] == plan['id'],
                    ))
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Eliminar plan'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _assignedPlans[_selectedDay!]?.removeWhere(
                          (p) =>
                              p['id'] == plan['id'] &&
                              p['time'] == plan['time'],
                        );
                        if (_assignedPlans[_selectedDay!]?.isEmpty ?? false) {
                          _assignedPlans.remove(_selectedDay);
                        }
                        final originalPlan = _availablePlans.firstWhere(
                          (p) => p['id'] == plan['id'],
                        );
                        originalPlan['isAssigned'] = false;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year + 1, now.month, now.day);

    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              child: TableCalendar(
                firstDay: firstDay,
                lastDay: lastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, isSelected: true);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildCalendarDay(day, isToday: true);
                  },
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  cellMargin: EdgeInsets.all(4),
                  cellPadding: EdgeInsets.all(0),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(child: _buildPlanDetailsConsole()),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final hasPlans = _assignedPlans[day]?.isNotEmpty ?? false;
    final isEnabled = _isDateInRange(day);
    final plans = _assignedPlans[day] ?? [];
    final planColor =
        plans.isNotEmpty
            ? plans.first['color'] ?? const Color(0xFFC6DA23)
            : const Color(0xFFC6DA23);

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        debugPrint('🎯 Intentando arrastrar plan al ${day.toString()}');
        debugPrint('   - ¿Fecha habilitada?: $isEnabled');

        if (!isEnabled) {
          debugPrint('   - Fecha fuera de rango');
          return false;
        }

        final isTemplate = details.data['isTemplate'] as bool;
        if (isTemplate) {
          final isAvailable = _isTimeSlotAvailable(day, details.data['time']);
          debugPrint('   - ¿Horario disponible?: $isAvailable');
          return isAvailable;
        }

        debugPrint('   - Moviendo plan existente');
        return true;
      },
      onAcceptWithDetails: (details) {
        if (!isEnabled) return;

        setState(() {
          final isTemplate = details.data['isTemplate'] as bool;
          final sourceDay = _selectedDay;
          final plan = Map<String, dynamic>.from(details.data)
            ..remove('isTemplate');

          if (!isTemplate && sourceDay != null) {
            _assignedPlans[sourceDay]?.removeWhere(
              (p) => p['id'] == plan['id'] && p['time'] == plan['time'],
            );
            if (_assignedPlans[sourceDay]?.isEmpty ?? false) {
              _assignedPlans.remove(sourceDay);
            }
          }

          if (_isTimeSlotAvailable(day, plan['time'])) {
            final plans = _assignedPlans[day] ?? [];
            plans.add(plan);
            plans.sort((a, b) => a['time'].compareTo(b['time']));
            _assignedPlans[day] = plans;
            _selectedDay = day;

            _showSnackBar(
              'Plan actualizado correctamente',
              backgroundColor: const Color(0xFFC6DA23),
            );
          } else {
            _showSnackBar(
              'Ya existe un plan para las ${plan['time']}',
              backgroundColor: Colors.orange,
            );
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getCalendarDayColor(
              isSelected: isSelected,
              isToday: isToday,
              hasPlans: hasPlans,
              isEnabled: isEnabled,
              isDragTarget: candidateData.isNotEmpty,
              planColor: planColor,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getCalendarDayBorderColor(
                isSelected: isSelected,
                hasPlans: hasPlans,
                isEnabled: isEnabled,
                isDragTarget: candidateData.isNotEmpty,
                planColor: planColor,
              ),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isEnabled ? Colors.black87 : Colors.grey,
                    fontWeight: isSelected || isToday ? FontWeight.bold : null,
                  ),
                ),
              ),
              if (hasPlans)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: planColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getCalendarDayColor({
    required bool isSelected,
    required bool isToday,
    required bool hasPlans,
    required bool isEnabled,
    required bool isDragTarget,
    Color planColor = const Color(0xFFC6DA23),
  }) {
    if (isDragTarget) return planColor.withAlpha(50);
    if (isSelected) return const Color(0xFF0067AC).withAlpha(50);
    if (isToday) return const Color(0xFF0067AC).withAlpha(20);
    if (hasPlans) return planColor.withAlpha(20);
    return isEnabled ? Colors.white : Colors.grey.withAlpha(20);
  }

  Color _getCalendarDayBorderColor({
    required bool isSelected,
    required bool hasPlans,
    required bool isEnabled,
    required bool isDragTarget,
    Color planColor = const Color(0xFFC6DA23),
  }) {
    if (isDragTarget) return planColor;
    if (isSelected) return const Color(0xFF0067AC);
    if (hasPlans) return planColor;
    return isEnabled ? Colors.grey.withAlpha(50) : Colors.grey.withAlpha(20);
  }

  Widget _buildPlanDetailsConsole() {
    if (_selectedDay == null) {
      return const Center(
        child: Text(
          'Seleccione un día para ver los detalles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final plans = _assignedPlans[_selectedDay] ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.event_note, color: Color(0xFF0067AC), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Planes para ${DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDay!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child:
              plans.isEmpty
                  ? const Center(
                    child: Text(
                      'No hay planes asignados para este día',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: plans.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: const Color(0xFFC6DA23).withAlpha(20),
                        child: _buildDraggablePlan(plan, false),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSyncedPlansSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planes de Pausa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSyncedPlans,
                color: const Color(0xFF0067AC),
              ),
            ],
          ),
          if (_availablePlans.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No hay planes disponibles',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _savePlan() async {
    debugPrint('🔄 Iniciando proceso de guardado del plan...');

    if (_formKey.currentState!.validate()) {
      try {
        debugPrint('✅ Formulario validado correctamente');

        final startDate = _parseDate(_startDateController.text);
        final endDate = _parseDate(_endDateController.text);

        debugPrint('📅 Validando fechas:');
        debugPrint('- Inicio: ${_startDateController.text}');
        debugPrint('- Fin: ${_endDateController.text}');

        if (startDate == null || endDate == null) {
          debugPrint('❌ Error: Fechas inválidas');
          _showSnackBar('Error: Fechas inválidas', backgroundColor: Colors.red);
          return;
        }

        if (_timeController.text.isEmpty) {
          debugPrint('❌ Error: Hora no seleccionada');
          _showSnackBar(
            'Error: Debe seleccionar una hora',
            backgroundColor: Colors.red,
          );
          return;
        }

        debugPrint('📋 Validando planes asignados...');
        debugPrint('- Total días con planes: ${_assignedPlans.length}');

        if (_assignedPlans.isEmpty) {
          debugPrint('❌ Error: No hay planes asignados');
          _showSnackBar(
            'Error: Debe asignar al menos un plan',
            backgroundColor: Colors.red,
          );
          return;
        }

        // Log assigned plans details
        _assignedPlans.forEach((date, plans) {
          debugPrint(
            '📅 Planes para ${DateFormat('dd/MM/yyyy').format(date)}:',
          );
          for (var plan in plans) {
            debugPrint('  - ${plan['name']} (${plan['time']})');
          }
        });

        // Convertir los planes asignados al formato correcto
        final convertedAssignedPlans = _assignedPlans.map((date, plans) {
          return MapEntry(
            date,
            plans
                .map(
                  (plan) => AssignedPlanItem(
                    id: plan['id'],
                    name: plan['name'],
                    time: plan['time'],
                    color:
                        (plan['color'] ?? const Color(0xFF0067AC)).toString(),
                  ),
                )
                .toList(),
          );
        });

        final notificationPlan = NotificationPlan(
          name: _nameController.text,
          startDate: startDate,
          endDate: endDate,
          time: _timeController.text,
          assignedPlans: convertedAssignedPlans,
          id: '', // ID vacío ya que es un nuevo plan
        );

        debugPrint('📤 Preparando envío al servidor...');
        debugPrint('📦 Plan a crear:');
        debugPrint('''
          Nombre: ${notificationPlan.name}
          Período: ${_formatDate(startDate)} - ${_formatDate(endDate)}
          Hora: ${notificationPlan.time}
          Total días: ${_assignedPlans.length}
          Total planes: ${_assignedPlans.values.fold(0, (sum, plans) => sum + plans.length)}
        ''');

        final notificationService = NotificationService();
        debugPrint('🔄 Enviando solicitud al servidor...');

        final createdPlan = await notificationService.createNotificationPlan(
          notificationPlan,
        );

        debugPrint('✅ Plan creado exitosamente');
        debugPrint('📎 ID asignado: ${createdPlan.id}');

        _showSnackBar('Plan de notificaciones guardado exitosamente');
        _clearForm();

        debugPrint('🎉 Proceso completado con éxito');
      } catch (e) {
        debugPrint('❌ Error durante el proceso de guardado:');
        debugPrint('- Mensaje: $e');
        debugPrint('- Tipo: ${e.runtimeType}');

        _showSnackBar(
          'Error al guardar el plan: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    } else {
      debugPrint('❌ Formulario inválido');
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Plan'),
            content: const Text(
              '¿Estás seguro de que deseas cancelar el plan? Los cambios no guardados se perderán.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                ),
                child: const Text('Sí, Cancelar'),
              ),
            ],
          ),
    );
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _timeController.clear();
      _assignedPlans.clear();
      for (var plan in _availablePlans) {
        plan['isAssigned'] = false;
      }
    });
  }

  bool _isDateInRange(DateTime day) {
    try {
      if (_startDateController.text.isEmpty ||
          _endDateController.text.isEmpty) {
        return false;
      }

      final startDate = _parseDate(_startDateController.text);
      final endDate = _parseDate(_endDateController.text);

      if (startDate == null || endDate == null) {
        debugPrint('❌ Error: Fechas inválidas');
        return false;
      }

      debugPrint('📅 Validando fecha: ${_formatDate(day)}');
      debugPrint('   - Inicio: ${_formatDate(startDate)}');
      debugPrint('   - Fin: ${_formatDate(endDate)}');

      final isInRange =
          (day.isAtSameMomentAs(startDate) || day.isAfter(startDate)) &&
          (day.isAtSameMomentAs(endDate) || day.isBefore(endDate));

      debugPrint('   - ¿En rango?: $isInRange');
      return isInRange;
    } catch (e) {
      debugPrint('❌ Error validando rango de fechas: $e');
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es').format(date);
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy', 'es').parse(date);
    } catch (e) {
      debugPrint('❌ Error parseando fecha "$date": $e');
      return null;
    }
  }

  bool _isTimeSlotAvailable(DateTime day, String time) {
    final plans = _assignedPlans[day] ?? [];
    return !plans.any((plan) => plan['time'] == time);
  }
}
