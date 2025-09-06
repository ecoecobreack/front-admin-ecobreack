import 'package:flutter/material.dart';
import '../../../../../widgets/web_video_player.dart';
import '../../../../../core/services/serv_actividades/drive_service.dart';

class ActivityPreviewDialog extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final int minTime;
  final int maxTime;
  final bool sensorEnabled;
  final Map<String, dynamic>? selectedVideo;

  const ActivityPreviewDialog({
    super.key,
    required this.title,
    required this.category,
    required this.description,
    required this.minTime,
    required this.maxTime,
    required this.sensorEnabled,
    required this.selectedVideo,
  });

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'tren superior':
        return const Color(0xFF0067AC);
      case 'tren inferior':
        return const Color(0xFFC6DA23);
      case 'movilidad articular':
        return Colors.orange;
      case 'estiramientos generales':
        return Colors.purple;
      default:
        return const Color(0xFF0067AC);
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'tren superior':
        return Icons.accessibility_new;
      case 'tren inferior':
        return Icons.directions_walk;
      case 'movilidad articular':
        return Icons.self_improvement;
      case 'estiramientos generales':
        return Icons.accessibility;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildVideoSection(),
                    _buildInstructionsSection(),
                    _buildTimerSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Row(
            children: [
              const SizedBox(width: 48),
              const Expanded(
                child: Text(
                  'Vista Previa de Actividad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaRounded',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        fontFamily: 'HelveticaRounded',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 16, color: categoryColor),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcon,
                  size: 32,
                  color: categoryColor.withAlpha(180),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (selectedVideo == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: WebVideoPlayer(
            embedUrl: DriveService.getEmbedUrl(selectedVideo!['id']),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    final instrucciones = description.split('\n');
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: categoryColor),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                  fontFamily: 'HelveticaRounded',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...instrucciones.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor, categoryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Duración del ejercicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$minTime - $maxTime segundos',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'HelveticaRounded',
            ),
          ),
          if (sensorEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51), // 0.2 * 255 ≈ 51255).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sensor de movimiento activado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
