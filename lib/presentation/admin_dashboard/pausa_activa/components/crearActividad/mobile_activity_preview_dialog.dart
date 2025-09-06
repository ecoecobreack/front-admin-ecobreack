import 'package:flutter/material.dart';
import '../../../../../widgets/web_video_player.dart';
import '../../../../../core/services/serv_actividades/drive_service.dart';

class MobileActivityPreviewDialog extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final int minTime;
  final int maxTime;
  final bool sensorEnabled;
  final Map<String, dynamic>? selectedVideo;

  const MobileActivityPreviewDialog({
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
      case 'visual':
        return const Color(0xFF2196F3); // Azul
      case 'auditiva':
        return const Color(0xFFE91E63); // Rosa
      case 'cognitiva':
        return const Color(0xFF9C27B0); // Morado
      case 'tren superior':
        return const Color(0xFF0067AC); // Azul corporativo
      case 'tren inferior':
        return const Color(0xFFC6DA23); // Verde corporativo
      case 'movilidad articular':
        return const Color(0xFFFF9800); // Naranja
      case 'estiramientos generales':
        return const Color(0xFF673AB7); // Morado oscuro
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
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = screenSize.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Fondo con gradiente
          Container(
            width: 600,
            height: maxHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  categoryColor,
                  categoryColor.withAlpha(200),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // Contenido principal
          Container(
            width: 600,
            height: maxHeight,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Header mejorado
                _buildHeader(),
                const SizedBox(height: 32),
                // Marco del dispositivo móvil
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withAlpha(30),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Column(
                        children: [
                          // Barra de estado
                          _buildStatusBar(),
                          // Contenido de la app
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: _buildMobileContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón de cerrar
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.phone_iphone, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vista Previa Móvil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: 'HelveticaRounded',
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: categoryColor),
      child: const Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Icon(Icons.wifi, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Icon(Icons.battery_full, color: Colors.white, size: 12),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white70),
        hoverColor: Colors.white10,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildMobileContent() {
    final instrucciones = description.split('\n');

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildContentHeader(),
          if (selectedVideo != null) _buildVideoSection(),
          _buildInstructions(instrucciones),
          _buildTimerSection(),
        ],
      ),
    );
  }

  Widget _buildContentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon, size: 14, color: categoryColor),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (selectedVideo == null) return const SizedBox.shrink();

    debugPrint('🎥 Construyendo sección de video');
    final videoId = selectedVideo!['id'];
    final videoUrl = DriveService.getEmbedUrl(videoId);

    // Asegurar permisos del video
    DriveService.ensureVideoAccess(videoId);

    debugPrint('🔗 URL del video configurada: $videoUrl');

    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: WebVideoPlayer(embedUrl: videoUrl),
    );
  }

  Widget _buildInstructions(List<String> instrucciones) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instrucciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...instrucciones.map((instruccion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(instruccion),
          )),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Duración',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$minTime - $maxTime segundos',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (sensorEnabled) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Sensor activado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0067AC).withAlpha(8) // Cambiado de withOpacity(0.03) a withAlpha(8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + 100, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
