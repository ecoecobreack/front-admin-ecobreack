import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../../../widgets/ring_stat.dart';

class UserStatsDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const UserStatsDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserStatsDialog> createState() => _UserStatsDialogState();
}

class _UserStatsDialogState extends State<UserStatsDialog> {
  Future<Map<String, dynamic>>? _statsData;
  String _selectedView = 'rings';
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String _searchType = 'day'; // 'day', 'month', 'year'

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      _statsData = ApiService().get('/admin/users/${widget.userId}/stats');
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error cargando estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1000,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0067AC).withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF0067AC).withAlpha(5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Seleccionar Fecha',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0067AC).withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSearchTypeSelector(),
                      ],
                    ),
                  ),
                  if (_searchType == 'day')
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.now(),
                        focusedDay: _focusedDate,
                        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDate = focusedDay;
                            _loadStats();
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF0067AC),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFC6DA23),
                            shape: BoxShape.circle,
                          ),
                        ),
                        locale: 'es_ES',
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    )
                  else if (_searchType == 'month')
                    _buildMonthPicker()
                  else
                    _buildYearPicker(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estadísticas de ${widget.userName}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0067AC),
                              ),
                            ),
                            Text(
                              'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        _buildViewSelector(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: _buildStatsContent()),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HelveticaRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Búsqueda Dinámica',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'day',
                label: Text('Día'),
                icon: Icon(Icons.calendar_today),
              ),
              ButtonSegment(
                value: 'month',
                label: Text('Mes'),
                icon: Icon(Icons.calendar_month),
              ),
              ButtonSegment(
                value: 'year',
                label: Text('Año'),
                icon: Icon(Icons.calendar_today_outlined),
              ),
            ],
            selected: {_searchType},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _searchType = selection.first;
                _loadStats();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Expanded(
      child: ListView.builder(
        itemCount: 12,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final month = DateTime(2024, index + 1);
          final isSelected = _selectedDate.month == index + 1;
          
          return ListTile(
            selected: isSelected,
            selectedTileColor: const Color(0xFF0067AC).withAlpha(20),
            title: Text(
              DateFormat.MMMM('es_ES').format(month),
              style: TextStyle(
                color: isSelected ? const Color(0xFF0067AC) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, index + 1);
                _loadStats();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return Expanded(
      child: ListView.builder(
        itemCount: years.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = _selectedDate.year == year;

          return ListTile(
            selected: isSelected,
            selectedTileColor: const Color(0xFF0067AC).withAlpha(20),
            title: Text(
              year.toString(),
              style: TextStyle(
                color: isSelected ? const Color(0xFF0067AC) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedDate = DateTime(year, _selectedDate.month);
                _loadStats();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildViewSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'rings',
          icon: Icon(Icons.donut_large),
        ),
        ButtonSegment(
          value: 'bars',
          icon: Icon(Icons.bar_chart),
        ),
      ],
      selected: {_selectedView},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() => _selectedView = newSelection.first);
      },
    );
  }

  Widget _buildStatsContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0067AC)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget(snapshot.error);
        }

        final stats = snapshot.data?['data'] ?? {};
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _selectedView == 'rings'
              ? _buildRingStats(stats)
              : _buildBarChart(stats),
        );
      },
    );
  }

  Widget _buildBarChart(Map<String, dynamic> stats) {
    final data = [
      stats['activities_done'] ?? 0,
      (stats['total_activities'] ?? 0) - (stats['activities_done'] ?? 0),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: stats['total_activities']?.toDouble() ?? 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: data[0].toDouble(),
                  color: const Color(0xFF9ACA60),
                  width: 60,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: stats['total_activities']?.toDouble() ?? 0,
                    color: const Color(0xFF9ACA60).withAlpha(30),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: data[1].toDouble(),
                  color: const Color(0xFFD0EA4A),
                  width: 60,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: stats['total_activities']?.toDouble() ?? 0,
                    color: const Color(0xFFD0EA4A).withAlpha(30),
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = ['Realizadas', 'Pendientes'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(
                        color: Color(0xFF0067AC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRingStats(Map<String, dynamic> stats) {
    final total = (stats['total_activities'] ?? 0).toDouble();
    final completed = (stats['activities_done'] ?? 0).toDouble();
    final time = (stats['total_time'] ?? 0).toDouble();
    final notCompleted = total - completed;
    final percentage = total > 0 ? completed / total : 0.0;
    final percentageNo = total > 0 ? notCompleted / total : 0.0;

    return Column(
      children: [
        RingStat(
          label: 'ACTIVIDADES\nREALIZADAS',
          value: completed.toStringAsFixed(0),
          percent: percentage,
          color: const Color(0xFF9ACA60),
          valueStyle: const TextStyle(
            fontSize: 33,
            fontWeight: FontWeight.bold,
            fontFamily: 'HelveticaRounded',
            color: Color(0xFF186188),
          ),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontFamily: 'HelveticaRounded',
            color: Color(0xFF9ACA60),
            fontWeight: FontWeight.w500,
          ),
          radius: 80.0,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RingStat(
              label: 'TOTAL',
              value: total.toStringAsFixed(0),
              percent: 1.0,
              color: const Color(0xFFD0EA4A),
              valueStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF186188),
              ),
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF186188),
              ),
            ),
            RingStat(
              label: 'TIEMPO',
              value: '${time.toStringAsFixed(0)} min',
              percent: 1.0,
              color: const Color(0xFF186188),
              valueStyle: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 179, 231, 7),
              ),
              labelStyle: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 179, 231, 7),
              ),
            ),
            RingStat(
              label: 'NO\nREALIZADAS',
              value: notCompleted.toStringAsFixed(0),
              percent: percentageNo,
              color: const Color(0xFFD0EA4A),
              valueStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF186188),
              ),
              labelStyle: const TextStyle(
                fontSize: 9,
                color: Color(0xFF186188),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loadStats();
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
