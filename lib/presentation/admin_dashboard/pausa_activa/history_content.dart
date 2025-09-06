import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/serv_actividades/history_service.dart';
import '../../../data/models/pause_history.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key});

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  List<PauseHistory> _pauseHistory = [];
  bool _isLoading = false;
  String _selectedFilter = 'week';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  // Add new variables for expandable sections
  bool _isStatsExpanded = false;
  bool _isTableExpanded = false;

  // Update color constants to match brand colors
  static const primaryColor = Color(0xFF0067AC); // Original brand blue
  static const backgroundColor = Color(0xFFF5F6F9); // Light background
  static const successColor = Color(0xFF4CAF50); // Success green
  static const warningColor = Color(0xFFFFA726); // Warning orange
  static const errorColor = Color(0xFFE53935); // Error red
  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Helper method to replace withOpacity
  Color _withAlpha(Color color, double opacity) {
    final alpha = (opacity * 255).round();
    return color.withAlpha(alpha);
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() => _isLoading = true);

      final history = await HistoryService.getPauseHistory(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;
      setState(() {
        _pauseHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpandableHeader(),
                const SizedBox(height: 16),
                _buildExpandableStats(constraints),
                const SizedBox(height: 16),
                _buildExpandableTable(constraints),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Historial de Pausas Activas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFilterChip('Última semana', 'week'),
              const SizedBox(width: 8),
              _buildFilterChip('Último mes', 'month'),
              const SizedBox(width: 8),
              _buildFilterChip('Último año', 'year'),
              const Spacer(),
              _buildDateRangePicker(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      selected: _selectedFilter == value,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          switch (value) {
            case 'week':
              _startDate = DateTime.now().subtract(const Duration(days: 7));
              break;
            case 'month':
              _startDate = DateTime.now().subtract(const Duration(days: 30));
              break;
            case 'year':
              _startDate = DateTime.now().subtract(const Duration(days: 365));
              break;
          }
          _endDate = DateTime.now();
          _loadHistory();
        });
      },
      selectedColor: _withAlpha(primaryColor, 0.15),
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? primaryColor : Colors.grey[700],
        fontWeight:
            _selectedFilter == value ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _withAlpha(primaryColor, 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _withAlpha(primaryColor, 0.2)),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(primaryColor, 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDateRangePicker(),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 18, color: primaryColor),
            const SizedBox(width: 12),
            Text(
              '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM').format(_endDate)}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _withAlpha(primaryColor, 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.arrow_drop_down, color: primaryColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final ThemeData theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          child: Container(padding: const EdgeInsets.all(16), child: child!),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _loadHistory();
      });
    }
  }

  Widget _buildExpandableStats(BoxConstraints constraints) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Estadísticas',
            _isStatsExpanded,
            () => setState(() => _isStatsExpanded = !_isStatsExpanded),
          ),
          if (_isStatsExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: constraints.maxHeight * 0.4,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatCard(
                              'Total Pausas',
                              _pauseHistory.length.toString(),
                              Icons.fitness_center,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Tiempo Total',
                              '${_calculateTotalTime()} min',
                              Icons.timer,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Promedio Diario',
                              (_pauseHistory.length / 7).toStringAsFixed(1),
                              Icons.trending_up,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(height: 200, child: _buildChart()),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(isExpanded ? 0 : 12),
          ),
          boxShadow: cardShadow,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _withAlpha(primaryColor, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _withAlpha(primaryColor, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const Text('');
                final date = DateTime.now().subtract(
                  Duration(days: 7 - value.toInt()),
                );
                return Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(7, (index) {
              return FlSpot(
                index.toDouble(),
                _pauseHistory
                    .where((p) {
                      final date = p.date;
                      final targetDate = DateTime.now().subtract(
                        Duration(days: 6 - index),
                      );
                      return date.day == targetDate.day &&
                          date.month == targetDate.month &&
                          date.year == targetDate.year;
                    })
                    .length
                    .toDouble(),
              );
            }),
            isCurved: true,
            color: primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _withAlpha(primaryColor, 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTable(BoxConstraints constraints) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isTableExpanded = !_isTableExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Registro Detallado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.file_download, color: primaryColor),
                    onPressed: _exportData,
                    tooltip: 'Exportar datos',
                  ),
                  Icon(
                    _isTableExpanded ? Icons.expand_less : Icons.expand_more,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (_isTableExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: constraints.maxHeight * 0.5,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Usuario',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Fecha',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Plan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Duración',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Completado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pauseHistory.length,
                      itemBuilder:
                          (context, index) =>
                              _buildHistoryRow(_pauseHistory[index]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(PauseHistory pause) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(pause.userName)),
          Expanded(
            flex: 2,
            child: Text(DateFormat('dd/MM/yyyy HH:mm').format(pause.date)),
          ),
          Expanded(flex: 2, child: Text(pause.planName)),
          Expanded(flex: 1, child: Text('${pause.duration} min')),
          Expanded(flex: 1, child: _buildCompletionRate(pause.completionRate)),
        ],
      ),
    );
  }

  Widget _buildCompletionRate(double rate) {
    final percentage = rate * 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _withAlpha(_getStatusColor(percentage), 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _withAlpha(_getStatusColor(percentage), 0.3)),
      ),
      child: Text(
        '${percentage.round()}%',
        style: TextStyle(
          color: _getStatusColor(percentage),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getStatusColor(double rate) {
    if (rate >= 80) return successColor;
    if (rate >= 50) return warningColor;
    return errorColor;
  }

  int _calculateTotalTime() {
    return _pauseHistory.fold(0, (sum, pause) => sum + pause.duration);
  }

  Future<void> _exportData() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Iniciando exportación...')));

      final url = await HistoryService.exportHistory(
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos exportados. URL: $url'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () {
              // Aquí podrías abrir la URL en el navegador
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
